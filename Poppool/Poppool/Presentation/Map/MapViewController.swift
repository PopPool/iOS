import UIKit
import FloatingPanel
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import GoogleMaps
import CoreLocation
import RxGesture


class MapViewController: BaseViewController, View {
    typealias Reactor = MapReactor


    
    // MARK: - Properties
    var currentCarouselStores: [MapPopUpStore] = []
    private var markerDictionary: [Int64: GMSMarker] = [:]

    private let clusteringManager = ClusteringManager()
    private var currentStores: [MapPopUpStore] = []
    var disposeBag = DisposeBag()
    let mainView = MapView()
    let carouselView = MapPopupCarouselView()
    private let locationManager = CLLocationManager()
    private var currentMarker: GMSMarker?
    private let storeListReactor = StoreListReactor()
    private let storeListViewController = StoreListViewController(reactor: StoreListReactor())
    private var listViewTopConstraint: Constraint?
    private var currentFilterBottomSheet: FilterBottomSheetViewController?
    private var filterChipsTopY: CGFloat = 0
    private var filterContainerBottomY: CGFloat {
        let frameInView = mainView.filterChips.convert(mainView.filterChips.bounds, to: view)
        return frameInView.maxY // 필터 컨테이너의 바닥 높이
    }

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

        carouselView.onCardScrolled = { [weak self] pageIndex in
            guard let self = self else { return }
            // 1) 현재 캐러셀 목록 중 index
            guard pageIndex >= 0, pageIndex < self.currentCarouselStores.count else { return }

            let store = self.currentCarouselStores[pageIndex]

            // 2) 지도 이동
            let camera = GMSCameraPosition(target: store.coordinate, zoom: 15)
            self.mainView.mapView.animate(to: camera)

            // 3) 이전 마커 해제
            if let currentMarker = self.currentMarker {
                let markerView = MapMarker()
                markerView.injection(with: .init(isSelected: false, isCluster: false))
                currentMarker.iconView = markerView
            }

            // 4) 새 마커 찾아 강조
            if let marker = self.findMarker(for: store) {
                let markerView = MapMarker()
                markerView.injection(with: .init(isSelected: true, isCluster: false))
                marker.iconView = markerView
                self.currentMarker = marker
            }
        }

        if let reactor = self.reactor {
               bind(reactor: reactor)
               bindViewport(reactor: reactor)  

            reactor.action.onNext(.fetchCategories)

           }

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
            make.bottom.equalToSuperview()
            listViewTopConstraint = make.top.equalToSuperview().offset(view.frame.height).constraint // 초기 숨김 상태
        }

        if let reactor = self.reactor {
                bind(reactor: reactor)
            }

        // 제스처 설정
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        storeListViewController.mainView.grabberHandle.addGestureRecognizer(panGesture)
        storeListViewController.mainView.addGestureRecognizer(panGesture)
        setupPanAndSwipeGestures()


//        setupMarker()
    }

    private let defaultZoomLevel: Float = 15.0 // 기본 줌 레벨


    private func setupPanAndSwipeGestures() {
        storeListViewController.mainView.grabberHandle.rx.swipeGesture(.up)
            .skip(1)
            .withUnretained(self)
            .subscribe { owner, _ in
                Logger.log(message: "⬆️ 위로 스와이프 감지", category: .debug)
                switch owner.modalState {
                case .bottom:
                    owner.animateToState(.middle)
                case .middle:
                    owner.animateToState(.top)
                case .top:
                    break
                }
            }
            .disposed(by: disposeBag)

        storeListViewController.mainView.grabberHandle.rx.swipeGesture(.down)
            .skip(1)
            .withUnretained(self)
            .subscribe { owner, _ in
                Logger.log(message: "⬇️ 아래로 스와이프 감지됨", category: .debug)
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
//                print("[DEBUG] List Button Tapped")
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



        mainView.filterChips.onRemoveLocation = {
            reactor.action.onNext(.clearFilters(.location))
        }
        mainView.filterChips.onRemoveCategory = {
            reactor.action.onNext(.clearFilters(.category))
        }

        Observable.combineLatest(
            reactor.state.map { $0.selectedLocationFilters }.distinctUntilChanged(),
            reactor.state.map { $0.selectedCategoryFilters }.distinctUntilChanged()
        ) { locationFilters, categoryFilters -> (String, String) in
            // 지역 필터 텍스트 포맷팅
            let locationText: String
            if locationFilters.isEmpty {
                locationText = "지역선택"
            } else if locationFilters.count > 1 {
                locationText = "\(locationFilters[0]) 외 \(locationFilters.count - 1)개"
            } else {
                locationText = locationFilters[0]
            }

            // 카테고리 필터 텍스트 포맷팅
            let categoryText: String
            if categoryFilters.isEmpty {
                categoryText = "카테고리"
            } else if categoryFilters.count > 1 {
                categoryText = "\(categoryFilters[0]) 외 \(categoryFilters.count - 1)개"
            } else {
                categoryText = categoryFilters[0]
            }
            return (locationText, categoryText)
        }
        .observe(on: MainScheduler.instance)
        .bind { [weak self] locationText, categoryText in
            Logger.log(
                message: """
                필터 업데이트:
                📍 위치: \(locationText)
                🏷️ 카테고리: \(categoryText)
                """,
                category: .debug
            )
            self?.mainView.filterChips.update(
                locationText: locationText,
                categoryText: categoryText
            )
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
        reactor.state.map { $0.searchResult }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] store in
                guard let self = self else { return }
                let camera = GMSCameraPosition.camera(
                    withLatitude: store.latitude,
                    longitude: store.longitude,
                    zoom: 15
                )
                self.mainView.mapView.animate(to: camera)
                self.addMarker(for: store)
            }
            .disposed(by: disposeBag)
        mainView.searchInput.onSearch = { [weak self] query in
            self?.reactor?.action.onNext(.searchTapped(query))
        }

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLoading in
                self?.mainView.searchInput.searchTextField.isEnabled = !isLoading
//                self?.mainView.searchInput.setLoading(isLoading)
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.searchResults }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] results in
                guard let self = self else { return }

                // 기존 데이터를 초기화
                self.mainView.mapView.clear()  // 기존 마커 제거
                self.storeListViewController.reactor?.action.onNext(.setStores([])) // 리스트 뷰 초기화
                self.carouselView.updateCards([]) // 캐러셀 초기화
                self.carouselView.isHidden = true // 캐러셀 숨기기

                guard !results.isEmpty else { return }

                // 1. 리스트 뷰 업데이트
                let storeItems = results.map { $0.toStoreItem() }
                self.storeListViewController.reactor?.action.onNext(.setStores(storeItems))

                // 2. 마커 추가
                self.addMarkers(for: results)

                // 3. 캐러셀 뷰 업데이트
                self.carouselView.updateCards(results)
                self.carouselView.isHidden = false

                // 4. 첫 번째 검색 결과로 지도 이동
                if let firstStore = results.first {
                    let camera = GMSCameraPosition.camera(
                        withLatitude: firstStore.latitude,
                        longitude: firstStore.longitude,
                        zoom: 15
                    )
                    self.mainView.mapView.animate(to: camera)
                }
            }
            .disposed(by: disposeBag)




        reactor.state.map { $0.searchResults.isEmpty }
            .distinctUntilChanged()
            .skip(1)  // 초기값 스킵
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isEmpty in
                guard let self = self else { return }
                if isEmpty {
                    self.showAlert(
                        title: "검색 결과 없음",
                        message: "검색 결과가 없습니다. 다른 키워드로 검색해보세요."
                    )
                }
            }
            .disposed(by: disposeBag)
    }


    

    // MARK: - List View Control
    private func toggleListView() {
//        print("[DEBUG] Current Modal State: \(modalState)")
//        print("[DEBUG] Current listViewTopConstraint offset: \(listViewTopConstraint?.layoutConstraints.first?.constant ?? 0)")

        UIView.animate(withDuration: 0.3) {
            let middleOffset = -self.view.frame.height * 0.7 
            self.listViewTopConstraint?.update(offset: middleOffset)
            self.modalState = .middle
            self.mainView.searchFilterContainer.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }

        // 상태 변경 후 로그
        Logger.log(
            message: """
            리스트뷰 상태 변경:
            현재 상태: \(modalState)
            현재 오프셋: \(listViewTopConstraint?.layoutConstraints.first?.constant ?? 0)
            """,
            category: .debug
        )    }


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
                let currentOffset = constraint.layoutConstraints.first?.constant ?? 0
                let newOffset = currentOffset + translation.y

                // 오프셋 제한 범위 설정
                let minOffset: CGFloat = filterContainerBottomY // 필터 컨테이너 바닥 제한
                let maxOffset: CGFloat = view.frame.height // 최하단 제한
                let clampedOffset = min(max(newOffset, minOffset), maxOffset)

                constraint.update(offset: clampedOffset)
                gesture.setTranslation(.zero, in: view)

                // 알파값 조절: 탑 상태에서만 적용
                if modalState == .top {
                    adjustMapViewAlpha(for: clampedOffset, minOffset: minOffset, maxOffset: maxOffset)
                }
            }

        case .ended:
            if let constraint = listViewTopConstraint {
                let currentOffset = constraint.layoutConstraints.first?.constant ?? 0
                let middleY = view.frame.height * 0.3 // 중간 지점 기준 높이
                let targetState: ModalState

                // 속도와 위치를 기반으로 상태 결정
                if velocity.y > 500 { // 아래로 빠르게 드래그
                    targetState = .bottom
                } else if velocity.y < -500 { // 위로 빠르게 드래그
                    targetState = .top
                } else if currentOffset < middleY * 0.7 {
                    targetState = .top
                } else if currentOffset < view.frame.height * 0.7 {
                    targetState = .middle
                } else {
                    targetState = .bottom
                }

                // 최종 상태에 따라 애니메이션 적용
                animateToState(targetState)
            }

        default:
            break
        }
    }

    private func adjustMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat) {
        let middleOffset = view.frame.height * 0.3 // 미들 상태 기준 높이

        if offset <= minOffset {
            mainView.mapView.alpha = 0 // 탑에서는 완전히 숨김
        } else if offset >= maxOffset {
            mainView.mapView.alpha = 1 // 바텀에서는 완전히 보임
        } else if offset <= middleOffset {
            // 탑 ~ 미들 사이에서는 알파값 점진적 증가
            let progress = (offset - minOffset) / (middleOffset - minOffset)
            mainView.mapView.alpha = progress
        } else {
            // 미들 ~ 바텀 사이에서는 항상 보임
            mainView.mapView.alpha = 1
        }
    }


    private func updateMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat) {
        let progress = (maxOffset - offset) / (maxOffset - minOffset) // 0(탑) ~ 1(바텀)
        mainView.mapView.alpha = max(0, min(progress, 1)) // 0(완전히 가림) ~ 1(완전히 보임)
    }
    private func animateToState(_ state: ModalState) {
        guard modalState != state else { return }
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, animations: {
            switch state {
            case .top:
                let filterChipsFrame = self.mainView.filterChips.convert(
                    self.mainView.filterChips.bounds,
                    to: self.view
                )
                self.mainView.mapView.alpha = 0 // 탑 상태에서는 숨김
                self.storeListViewController.setGrabberHandleVisible(false)
                self.listViewTopConstraint?.update(offset: filterChipsFrame.maxY)
                self.mainView.searchInput.setBackgroundColor(.g50)



            case .middle:
                self.storeListViewController.setGrabberHandleVisible(true)
                // 필터 컨테이너 바닥 높이를 최소값으로 사용
                let offset = max(self.view.frame.height * 0.3, self.filterContainerBottomY)
                self.listViewTopConstraint?.update(offset: offset)
                self.storeListViewController.mainView.layer.cornerRadius = 20
                self.storeListViewController.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.mainView.mapView.alpha = 1 // 미들 상태에서는 항상 보임
                self.mainView.mapView.isHidden = false
                self.mainView.searchInput.setBackgroundColor(.white)


            case .bottom:
                self.storeListViewController.setGrabberHandleVisible(true)
                self.listViewTopConstraint?.update(offset: self.view.frame.height) // 화면 아래로 숨김
                self.mainView.mapView.alpha = 1 // 바텀 상태에서는 항상 보임
                self.mainView.mapView.isHidden = false
                self.mainView.searchInput.setBackgroundColor(.white)

            }

            self.view.layoutIfNeeded()
        }) { _ in
            self.modalState = state
            Logger.log(message: ". 현재 상태: \(state)", category: .debug)
        }
    }


    // MARK: - Clustering
    private func updateMapWithClustering() {
        let currentZoom = mainView.mapView.camera.zoom
        Logger.log(message: "현재 줌 레벨: \(currentZoom)", category: .debug)

        if currentZoom >= 12 {
            // 줌 레벨 12 이상은 개별 마커 모드로 전환
            Logger.log(message: "개별 마커 모드 활성화", category: .debug)
            updateIndividualMarkers(currentStores)
        } else {
            Logger.log(message: "클러스터 마커 모드 활성화", category: .debug)
            let clusters = clusteringManager.clusterStores(currentStores, at: currentZoom)
            updateClusterMarkers(clusters)
        }
    }



        private func updateIndividualMarkers(_ stores: [MapPopUpStore]) {
            mainView.mapView.clear()
            Logger.log(message: "📍 개별 마커 업데이트 (총 \(stores.count)개)", category: .debug)

            for store in stores {
                let marker = GMSMarker()
                marker.position = store.coordinate
                marker.userData = store

                let markerView = MapMarker()
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: false
                ))
                marker.iconView = markerView
                marker.map = mainView.mapView
                Logger.log(message: "🟢 마커 추가: \(store.name), 위치: (\(store.latitude), \(store.longitude))", category: .debug)

            }
        }

        private func updateClusterMarkers(_ clusters: [ClusterMarkerData]) {
            mainView.mapView.clear()
            Logger.log(message: "🔴 클러스터 마커 업데이트 (총 \(clusters.count)개)", category: .debug)

            for cluster in clusters {
                let marker = GMSMarker()
                marker.position = cluster.cluster.coordinate
                marker.userData = cluster

                let markerView = MapMarker()
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: true,
                    regionName: cluster.cluster.name,
                    count: cluster.storeCount
                ))
                marker.iconView = markerView
                marker.map = mainView.mapView
                Logger.log(
                    message: "🔴 클러스터 추가: \(cluster.cluster.name), 위치: (\(cluster.cluster.coordinate.latitude), \(cluster.cluster.coordinate.longitude)), 포함된 마커 수: \(cluster.storeCount)",
                    category: .debug
                )
            }
        }

    func presentFilterBottomSheet(for filterType: FilterType) {
        let sheetReactor = FilterBottomSheetReactor()
        let viewController = FilterBottomSheetViewController(reactor: sheetReactor)

        let initialIndex = (filterType == .location) ? 0 : 1
        viewController.containerView.segmentedControl.selectedSegmentIndex = initialIndex
        sheetReactor.action.onNext(.segmentChanged(initialIndex))

        viewController.onSave = { [weak self] filterData in
              guard let self = self else { return }

            Logger.log(
                message: """
                필터 저장:
                📍 위치: \(filterData.locations)
                🏷️ 카테고리: \(filterData.categories)
                """,
                category: .debug
            )

              self.reactor?.action.onNext(.updateBothFilters(
                  locations: filterData.locations,
                  categories: filterData.categories
              ))
              self.reactor?.action.onNext(.filterTapped(nil))
          }

        viewController.onSave = { [weak self] filterData in
            guard let self = self else { return }
            self.reactor?.action.onNext(.updateBothFilters(
                locations: filterData.locations,
                categories: filterData.categories
            ))
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
    //기본 마커
    private func addMarkers(for stores: [MapPopUpStore]) {
        mainView.mapView.clear()
        markerDictionary.removeAll()

        for store in stores {
            let marker = GMSMarker()
            marker.position = store.coordinate
            marker.userData = store

            let markerView = MapMarker()
            markerView.injection(with: .init(
                isSelected: false,
                isCluster: false
            ))
            marker.iconView = markerView
            marker.map = mainView.mapView
            markerDictionary[store.id] = marker
        }
    }
    private func updateListView(with results: [MapPopUpStore]) {
        // MapPopUpStore 배열을 StoreItem 배열로 변환
        let storeItems = results.map { $0.toStoreItem() }
        storeListViewController.reactor?.action.onNext(.setStores(storeItems))
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }



    // MARK: - Location
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            Logger.log(
                message: "위치 서비스가 비활성화되었습니다. 설정에서 권한을 확인해주세요.",
                category: .error
            )
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 15
        )
        mainView.mapView.animate(to: camera)

        // 현재 위치 마커 추가 코드 제거
        locationManager.stopUpdatingLocation()
    }

}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // (1) 클러스터 마커
        if let clusterData = marker.userData as? ClusterMarkerData {
            // 줌 레벨 조정
            let clusterToIndividualZoom: Float = 14.0
            let currentZoom = mapView.camera.zoom
            let newZoom: Float = (currentZoom < clusterToIndividualZoom)
                ? clusterToIndividualZoom
                : min(mapView.maxZoom, currentZoom + 1)

            let camera = GMSCameraPosition(target: marker.position, zoom: newZoom)
            mapView.animate(to: camera)

            // 여러 스토어를 캐러셀에
            let multiStores = clusterData.cluster.stores
            carouselView.updateCards(multiStores)
            carouselView.isHidden = multiStores.isEmpty
            self.currentCarouselStores = multiStores

            // 만약 클러스터 자체 마커를 강조하고 싶으면
            // marker.iconView = ...
            return true
        }

        // (2) 단일 마커
        // 이전 마커 해제
        if let previousMarker = currentMarker {
                       let markerView = MapMarker()
                       markerView.injection(with: .init(isSelected: false, isCluster: false))
                       previousMarker.iconView = markerView
                   }

                   // 2-2) 새 마커 강조
                   let markerView = MapMarker()
                   markerView.injection(with: .init(isSelected: true, isCluster: false))
                   marker.iconView = markerView
                   currentMarker = marker

                   if let store = marker.userData as? MapPopUpStore {

                       // (A) 캐러셀에 “뷰포트 내 스토어들” 전체를 표시
                       carouselView.updateCards(currentStores)
                       carouselView.isHidden = currentStores.isEmpty
                       self.currentCarouselStores = currentStores

                       // (B) 탭한 마커에 해당하는 스토어 찾아 scroll
                       if let idx = currentStores.firstIndex(where: { $0.id == store.id }) {
                           carouselView.scrollToCard(index: idx)
                       }
                   }
                   return true
               }


    // 지도 움직임
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        updateMapWithClustering()
    }

    // 지도 빈 공간 탭 → 해제
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let currentMarker = currentMarker {
            let markerView = MapMarker()
            markerView.injection(with: .init(isSelected: false, isCluster: false))
            currentMarker.iconView = markerView
        }
        currentMarker = nil
        carouselView.isHidden = true
        carouselView.updateCards([])
        self.currentCarouselStores = []
    }
}


extension MapViewController {
    func bindViewport(reactor: MapReactor) {
        mainView.mapView.rx.idleAtPosition
            // idleAtPosition 이벤트가 발생하면 현재 카메라 위치를 반환
            .map { [weak self] in self?.mainView.mapView.camera }
            .compactMap { $0 }
            // 카메라 변화가 미세하면 업데이트하지 않도록 비교 (임계값: 위도/경도 0.01, 줌 0.1)
            .distinctUntilChanged { (cam1, cam2) -> Bool in
                let latDiff = abs(cam1.target.latitude - cam2.target.latitude)
                let lonDiff = abs(cam1.target.longitude - cam2.target.longitude)
                let zoomDiff = abs(cam1.zoom - cam2.zoom)
                return latDiff < 0.01 && lonDiff < 0.01 && zoomDiff < 0.1
            }
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { [weak self] _ -> MapReactor.Action? in
                guard let self = self else { return nil }
                let bounds = self.mainView.mapView.projection.visibleRegion()
                return .viewportChanged(
                    northEastLat: bounds.farRight.latitude,
                    northEastLon: bounds.farRight.longitude,
                    southWestLat: bounds.nearLeft.latitude,
                    southWestLon: bounds.nearLeft.longitude
                )
            }
            .compactMap { $0 }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.viewportStores }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] stores in
                guard let self = self else { return }
                self.currentStores = stores
                self.updateMapWithClustering()
            }
            .disposed(by: disposeBag)
    }



    private func findMarker(for store: MapPopUpStore) -> GMSMarker? {
        return markerDictionary[store.id]
    }
    /// (A) 공통 함수: 마커 탭 시 해야 할 로직
    private func handleMarkerTap(_ marker: GMSMarker) -> Bool {
        // 1) 클러스터인지
        if let clusterData = marker.userData as? ClusterMarkerData {
            let clusterToIndividualZoom: Float = 14.0
            let currentZoom = mainView.mapView.camera.zoom
            let newZoom: Float = (currentZoom < clusterToIndividualZoom)
                ? clusterToIndividualZoom
                : min(mainView.mapView.maxZoom, currentZoom + 1)

            let camera = GMSCameraPosition(target: marker.position, zoom: newZoom)
            mainView.mapView.animate(to: camera)

            // 여러 스토어 캐러셀 업데이트
            let multiStores = clusterData.cluster.stores
            carouselView.updateCards(multiStores)
            carouselView.isHidden = multiStores.isEmpty
            currentCarouselStores = multiStores
            // 클러스터 마커 강조/해제 등 필요시 추가

            return true
        }

        // 2) 일반 마커일 때
        if let previousMarker = currentMarker {
            let markerView = MapMarker()
            markerView.injection(with: .init(isSelected: false, isCluster: false))
            previousMarker.iconView = markerView
        }

        // 새 마커 강조
        let markerView = MapMarker()
        markerView.injection(with: .init(isSelected: true, isCluster: false))
        marker.iconView = markerView
        currentMarker = marker

        if let store = marker.userData as? MapPopUpStore {
            // 캐러셀에 뷰포트 내 스토어들을 모두 표시
            carouselView.updateCards(currentStores)
            carouselView.isHidden = currentStores.isEmpty
            currentCarouselStores = currentStores

            // 탭한 스토어가 몇 번째인지 찾아서 스크롤
            if let idx = currentStores.firstIndex(where: { $0.id == store.id }) {
                carouselView.scrollToCard(index: idx)
            }
        }

        return true
    }


    private func getCurrentViewportBounds() -> (northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D) {
        let region = mainView.mapView.projection.visibleRegion()
        return (northEast: region.farRight, southWest: region.nearLeft)
    }
    // 커스텀 마커
    private func updateMarkers(with stores: [MapPopUpStore]) {
        mainView.mapView.clear()
        stores.forEach { store in
            let marker = GMSMarker()
            marker.position = store.coordinate
            marker.userData = store

            let markerView = MapMarker()
            markerView.injection(with: store.toMarkerInput())
            marker.iconView = markerView
            marker.map = mainView.mapView
        }
    }
}

// MARK: - Reactive Extensions
extension Reactive where Base: GMSMapView {
    var delegate: DelegateProxy<GMSMapView, GMSMapViewDelegate> {
        return GMSMapViewDelegateProxy.proxy(for: base)
    }

    var didChangePosition: Observable<Void> {
        let proxy = GMSMapViewDelegateProxy.proxy(for: base)
        return proxy.didChangePositionSubject.asObservable()
    }

    var idleAtPosition: Observable<Void> {
        let proxy = GMSMapViewDelegateProxy.proxy(for: base)
        return proxy.idleAtPositionSubject.asObservable()
    }
}


