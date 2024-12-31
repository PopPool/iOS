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

    private var currentFilterBottomSheet: FilterBottomSheetViewController?
    private var filterChipsTopY: CGFloat = 0

    var fpc: FloatingPanelController?

    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            let frameInView = self.mainView.filterChips.convert(self.mainView.filterChips.bounds, to: self.view)
            self.filterChipsTopY = frameInView.minY

            print("[DEBUG] filterChipsTopY after layout: \(self.filterChipsTopY)")
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

            view.addSubview(carouselView)
            carouselView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(140)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            }

            carouselView.isHidden = true
            mainView.mapView.delegate = self
        }

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.5666, longitude: 126.9784)
        let markerView = MapMarker()
        markerView.injection(with: .init(title: "서울", count: 3))
        marker.iconView = markerView
        marker.map = mainView.mapView
        markerView.frame = CGRect(x: 0, y: 0, width: 80, height: 28)
    }

    func bind(reactor: Reactor) {
        mainView.filterChips.locationChip.rx.tap
            .map { Reactor.Action.filterTapped(.location) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.filterChips.categoryChip.rx.tap
            .map { Reactor.Action.filterTapped(.category) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.listButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self else { return }

                let reactor = StoreListReactor()
                let listVC = StoreListViewController(reactor: reactor)

                let fpc = FloatingPanelController()
                self.fpc = fpc
                fpc.delegate = self
                fpc.set(contentViewController: listVC)
                fpc.layout = StoreListPanelLayout()
                fpc.surfaceView.grabberHandle.isHidden = true
                fpc.surfaceView.layer.shadowColor = UIColor.clear.cgColor
                fpc.surfaceView.layer.shadowRadius = 0
                fpc.surfaceView.layer.shadowOffset = .zero
                fpc.surfaceView.layer.shadowOpacity = 0
                fpc.addPanel(toParent: self)
            }
            .disposed(by: disposeBag)

        mainView.locationButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.locationManager.startUpdatingLocation()
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.selectedLocationFilters }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] locationFilters in
                guard let self = self else { return }
                let locationText = locationFilters.isEmpty
                ? "지역선택"
                : (locationFilters.count > 1 ? "\(locationFilters[0]) 외 \(locationFilters.count - 1)개" : locationFilters[0])
                self.mainView.filterChips.update(locationText: locationText, categoryText: nil)
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.selectedCategoryFilters }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] categoryFilters in
                guard let self = self else { return }
                let categoryText = categoryFilters.isEmpty
                ? "카테고리"
                : (categoryFilters.count > 1 ? "\(categoryFilters[0]) 외 \(categoryFilters.count - 1)개" : categoryFilters[0])
                self.mainView.filterChips.update(locationText: nil, categoryText: categoryText)
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

    func addMarker(for store: MapPopUpStore) {
        let marker = GMSMarker()
        marker.position = store.coordinate
        marker.userData = store

        let markerView = MapMarker()
        markerView.injection(with: store.toMarkerInput())
        marker.iconView = markerView
        marker.map = mainView.mapView
    }

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
}

// MARK: - FloatingPanelControllerDelegate
extension MapViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        let panelY = fpc.surfaceView.frame.minY
//        print("[DEBUG] panelY: \(panelY), filterChipsTopY: \(filterChipsTopY)")

        let threshold: CGFloat = 40.0

        if abs(panelY - filterChipsTopY) <= threshold {
            transitionToFullScreen(fpc: fpc)
        } else if panelY > filterChipsTopY + threshold {
            restoreMapView(fpc: fpc)
        }
    }

    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        switch fpc.state {
        case .full:
            transitionToFullScreen(fpc: fpc)
        case .half, .tip:
            restoreMapView(fpc: fpc)
        default:
            break
        }
    }

    private func transitionToFullScreen(fpc: FloatingPanelController) {
        if let listVC = fpc.contentViewController as? StoreListViewController {
            // 상태 변경 전에 레이아웃 준비
            listVC.view.layoutIfNeeded()
            listVC.mainView.collectionView.layoutIfNeeded()

            UIView.animate(withDuration: 0.3) {
                self.mainView.alpha = 0
                self.mainView.isHidden = true
                listVC.view.backgroundColor = .white

                // 상태 변경
                listVC.updateHeaderVisibility(true)
                listVC.view.layoutIfNeeded()
            }
        }
    }


    private func restoreMapView(fpc: FloatingPanelController) {
        UIView.animate(withDuration: 0.3) {
            self.mainView.alpha = 1
            self.mainView.isHidden = false

            if let listVC = fpc.contentViewController as? StoreListViewController {
                listVC.view.backgroundColor = .clear
                listVC.updateHeaderVisibility(false)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MapViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let fpc = self.fpc else { return }

        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = .zero
            fpc.move(to: .half, animated: true)
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
        print("[DEBUG] Marker tapped")

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

extension MapViewController {
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
