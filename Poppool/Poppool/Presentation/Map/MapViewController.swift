import UIKit
import FloatingPanel
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import GoogleMaps
import CoreLocation

final class MapViewController: BaseViewController, View {
    typealias Reactor = MapReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()
    let mainView = MapView()
    let carouselView = MapPopupCarouselView()
    private let locationManager = CLLocationManager()
    private var currentMarker: GMSMarker?
    private let storeListViewController = StoreListViewController(reactor: StoreListReactor())
    private var listViewTopConstraint: Constraint?
    private var currentFilterBottomSheet: FilterBottomSheetViewController?
    private var filterChipsTopY: CGFloat = 0

    enum ModalState {
        case top
        case middle
        case bottom
    }

    private var modalState: ModalState = .bottom

    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            let frameInView = self.mainView.filterChips.convert(self.mainView.filterChips.bounds, to: self.view)
            self.filterChipsTopY = frameInView.minY
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        checkLocationAuthorization()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Setup
    private func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(carouselView)
        carouselView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        carouselView.isHidden = true
        mainView.mapView.delegate = self

        // 리스트뷰 설정
        addChild(storeListViewController)
        view.addSubview(storeListViewController.view)
        storeListViewController.didMove(toParent: self)

        storeListViewController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            listViewTopConstraint = make.top.equalTo(view.snp.bottom).constraint // 초기 숨김 상태
            make.height.equalTo(view.frame.height)
        }

        // 제스처 설정
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        storeListViewController.mainView.grabberHandle.addGestureRecognizer(panGesture)
        storeListViewController.mainView.addGestureRecognizer(panGesture)


        setupMarker()
    }

    private func setupMarker() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.5666, longitude: 126.9784)
        let markerView = MapMarker()
        markerView.injection(with: .init(title: "서울", count: 3))
        marker.iconView = markerView
        marker.map = mainView.mapView
        markerView.frame = CGRect(x: 0, y: 0, width: 80, height: 28)
    }

    private func setupPanAndSwipeGestures() {
        storeListViewController.mainView.grabberHandle.rx.swipeGesture(.up)
            .withUnretained(self)
            .subscribe { owner, _ in
                print("[DEBUG] Swipe Up Gesture Detected")
                owner.animateToState(.top)
            }
            .disposed(by: disposeBag)

        storeListViewController.mainView.grabberHandle.rx.swipeGesture(.down)
            .withUnretained(self)
            .subscribe { owner, _ in
                print("[DEBUG] Swipe Down Gesture Detected")
                switch owner.modalState {
                case .top:
                    owner.animateToState(.middle)
                case .middle:
                    owner.animateToState(.bottom)
                case .bottom:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Bind
    func bind(reactor: Reactor) {
        // 필터 관련 바인딩
        mainView.filterChips.locationChip.rx.tap
            .map { Reactor.Action.filterTapped(.location) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.filterChips.categoryChip.rx.tap
            .map { Reactor.Action.filterTapped(.category) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 리스트 버튼 탭
        mainView.listButton.rx.tap
            .withUnretained(self)
            .subscribe { owner, _ in
                print("[DEBUG] List Button Tapped")
                owner.animateToState(.middle) // 버튼 눌렀을 때 상태를 middle로 변경
            }
            .disposed(by: disposeBag)




        // 위치 버튼
        mainView.locationButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.locationManager.startUpdatingLocation()
            }
            .disposed(by: disposeBag)

        // 필터 상태 업데이트
        reactor.state.map { $0.selectedLocationFilters }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] filters in
                self?.mainView.filterChips.update(
                    locationText: filters.first ?? "지역선택",
                    categoryText: nil
                )
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.selectedCategoryFilters }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] filters in
                self?.mainView.filterChips.update(
                    locationText: nil,
                    categoryText: filters.first ?? "카테고리"
                )
            }
            .disposed(by: disposeBag)

        mainView.filterChips.onRemoveLocation = {
            reactor.action.onNext(.clearFilters(.location))
        }
        mainView.filterChips.onRemoveCategory = {
            reactor.action.onNext(.clearFilters(.category))
        }

        Observable.combineLatest(
            reactor.state.map { $0.selectedLocationFilters.isEmpty },
            reactor.state.map { $0.selectedCategoryFilters.isEmpty }
        )
        .observe(on: MainScheduler.instance)
        .bind { [weak self] isLocationEmpty, isCategoryEmpty in
            guard let self = self else { return }
            if isLocationEmpty {
                self.mainView.filterChips.update(locationText: "지역선택", categoryText: nil)
            }
            if isCategoryEmpty {
                self.mainView.filterChips.update(locationText: nil, categoryText: "카테고리")
            }
        }
        .disposed(by: disposeBag)

        reactor.state.map { $0.activeFilterType }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] filterType in
                guard let self = self else { return }
                if let filterType = filterType {
                    self.presentFilterBottomSheet(for: filterType)
                } else {
                    self.dismissFilterBottomSheet()
                }
            })
            .disposed(by: disposeBag)
    }
    

    // MARK: - List View Control
    private func toggleListView() {
        print("[DEBUG] Current Modal State: \(modalState)")
        print("[DEBUG] Current listViewTopConstraint offset: \(listViewTopConstraint?.layoutConstraints.first?.constant ?? 0)")

        UIView.animate(withDuration: 0.3) {
            let middleOffset = -self.view.frame.height * 0.7 
            self.listViewTopConstraint?.update(offset: middleOffset)
            self.modalState = .middle
            self.mainView.searchFilterContainer.backgroundColor = .clear
            print("[DEBUG] Changing state to Middle")
            print("[DEBUG] Updated offset: \(middleOffset)")
            self.view.layoutIfNeeded()
        }

        // 상태 변경 후 로그
        print("[DEBUG] New Modal State: \(modalState)")
        print("[DEBUG] New listViewTopConstraint offset: \(listViewTopConstraint?.layoutConstraints.first?.constant ?? 0)")
    }

    func addMarker(for store: MapPopUpStore) {
          let marker = GMSMarker()
          marker.position = store.coordinate
          marker.userData = store

          let markerView = MapMarker()
          markerView.injection(with: store.toMarkerInput())
          marker.iconView = markerView
          marker.map = mainView.mapView
      }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            if let constraint = listViewTopConstraint {
                let searchFilterFrame = self.mainView.searchFilterContainer.convert(
                    self.mainView.searchFilterContainer.bounds,
                    to: self.view
                )
                let filterChipsFrame = self.mainView.filterChips.convert(
                    self.mainView.filterChips.bounds,
                    to: self.view
                )
                let minOffset = searchFilterFrame.minY + filterChipsFrame.maxY + 12
                let maxOffset = view.frame.height

                let newOffset = constraint.layoutConstraints.first?.constant ?? 0 + translation.y
                let clampedOffset = min(max(newOffset, minOffset), maxOffset)

                constraint.update(offset: clampedOffset)
                gesture.setTranslation(.zero, in: view)

                let progress = (maxOffset - clampedOffset) / (maxOffset - minOffset)
                mainView.searchFilterContainer.alpha = progress
            }

        case .ended:
            let currentOffset = listViewTopConstraint?.layoutConstraints.first?.constant ?? 0
            let targetState: ModalState

            if velocity.y > 500 {
                targetState = .bottom
            } else if velocity.y < -500 {
                targetState = .top
            } else {
                let middleY = view.frame.height * 0.4
                if currentOffset < middleY * 0.7 {
                    targetState = .top
                } else if currentOffset < view.frame.height * 0.7 {
                    targetState = .middle
                } else {
                    targetState = .bottom
                }
            }

            print("[DEBUG] Pan Ended - Current Offset: \(currentOffset), Velocity Y: \(velocity.y)")
            modalState = targetState
            animateToState(targetState)

        default:
            break
        }
    }


    private func animateToState(_ state: ModalState) {
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, animations: {
            switch state {
            case .top:

                let filterChipsFrame = self.mainView.filterChips.convert(
                    self.mainView.filterChips.bounds,
                    to: self.view
                )
                self.mainView.mapView.isHidden = true
                self.storeListViewController.setGrabberHandleVisible(false)
                self.storeListViewController.mainView.layer.cornerRadius = 0
                self.storeListViewController.view.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalToSuperview().offset(filterChipsFrame.maxY)
                    make.bottom.equalToSuperview()
                }

                self.mainView.searchFilterContainer.backgroundColor = .white
                self.mainView.searchFilterContainer.alpha = 1

            case .middle:
                self.storeListViewController.setGrabberHandleVisible(true)
                self.storeListViewController.view.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalToSuperview().offset(self.view.frame.height * 0.3) // 70% 가려짐
                    make.height.equalTo(self.view.frame.height)
                    self.storeListViewController.mainView.layer.cornerRadius = 20
                    self.storeListViewController.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    self.mainView.mapView.isHidden = false

                }
                self.mainView.searchFilterContainer.backgroundColor = .clear

            case .bottom:
                self.storeListViewController.setGrabberHandleVisible(true)
                self.storeListViewController.view.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalTo(self.view.snp.bottom)
                    make.height.equalTo(self.view.frame.height)
                    self.mainView.mapView.isHidden = false

                }
                self.mainView.searchFilterContainer.backgroundColor = .clear
                self.mainView.searchFilterContainer.alpha = 1
            }

            self.view.layoutIfNeeded()
        }) { _ in
            self.modalState = state
        }
    }




    // MARK: - Filter Bottom Sheet
    func presentFilterBottomSheet(for filterType: FilterType) {
        let sheetReactor = FilterBottomSheetReactor()
        let viewController = FilterBottomSheetViewController(reactor: sheetReactor)

        let initialIndex = (filterType == .location) ? 0 : 1
        viewController.containerView.segmentedControl.selectedSegmentIndex = initialIndex
        sheetReactor.action.onNext(FilterBottomSheetReactor.Action.segmentChanged(initialIndex))

        viewController.onSave = { [weak self] (selectedOptions: [String]) in
            guard let self = self else { return }
            self.reactor?.action.onNext(.filterUpdated(filterType, selectedOptions))
            self.reactor?.action.onNext(.filterTapped(nil))
        }

        viewController.onDismiss = { [weak self] in
            self?.reactor?.action.onNext(.filterTapped(nil))
        }

        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: false) {
            viewController.showBottomSheet()
        }

        currentFilterBottomSheet = viewController
    }
    

    private func dismissFilterBottomSheet() {
        if let bottomSheet = currentFilterBottomSheet {
            bottomSheet.hideBottomSheet()
        }
        currentFilterBottomSheet = nil
    }

    // MARK: - Location
    private func checkLocationAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("위치 서비스가 비활성화되었습니다. 설정에서 권한을 확인해주세요.")
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude,
                                            zoom: 15)
        mainView.mapView.animate(to: camera)

        let currentLocationStore = MapPopUpStore(
            id: 0,
            category: "현재 위치",
            name: "현위치 팝업",
            address: "현재 위치 기반 주소",
            startDate: "2024.01.01",
            endDate: "2024.12.31",
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            markerId: 0,
            markerTitle: "현재 위치",
            markerSnippet: "현재 위치의 팝업스토어"
        )

        addMarker(for: currentLocationStore)
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let dummyStore1 = MapPopUpStore(
            id: 1,
            category: "카페",
            name: "팝업스토어명 팝업스토어명 최대 2줄 말줄임...",
            address: "서울특별시 중구",
            startDate: "2024.01.01",
            endDate: "2024.12.31",
            latitude: 37.5665,
            longitude: 126.9780,
            markerId: 1,
            markerTitle: "서울",
            markerSnippet: "팝업스토어"
        )
        let dummyStore2 = MapPopUpStore(
            id: 2,
            category: "전시/예술",
            name: "전시 팝업스토어 팝업스토어명 최대 2줄 말줄임...",
            address: "서울특별시 강남구",
            startDate: "2024.06.01",
            endDate: "2024.12.31",
            latitude: 37.4980,
            longitude: 127.0276,
            markerId: 2,
            markerTitle: "강남",
            markerSnippet: "전시 팝업스토어"
        )

        carouselView.updateCards([dummyStore1, dummyStore2])
        carouselView.isHidden = false

        return true
    }
}
