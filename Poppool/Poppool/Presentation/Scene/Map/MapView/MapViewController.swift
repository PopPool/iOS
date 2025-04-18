import CoreLocation
import FloatingPanel
import NMapsMap
import ReactorKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import UIKit

struct CoordinateKey: Hashable {
    let lat: Int
    let lng: Int

    init(latitude: Double, longitude: Double) {
        self.lat = Int(latitude * 1_000_00)
        self.lng = Int(longitude * 1_000_00)
    }
}

class MapViewController: BaseViewController, View,
                        CLLocationManagerDelegate,
                        NMFMapViewTouchDelegate,
                        NMFMapViewCameraDelegate,
                        UIGestureRecognizerDelegate {
    typealias Reactor = MapReactor

    var currentTooltipView: UIView?
    var currentTooltipStores: [MapPopUpStore] = []
    var currentTooltipCoordinate: NMGLatLng?

    // MARK: - Properties
    var markerStyler: MarkerStyling = DefaultMarkerStyler()
    private var storeDetailsCache: [Int64: StoreItem] = [:]
    var isMovingToMarker = false
    var currentCarouselStores: [MapPopUpStore] = []
    var markerDictionary: [Int64: NMFMarker] = [:]
    var individualMarkerDictionary: [Int64: NMFMarker] = [:]
    var clusterMarkerDictionary: [String: NMFMarker] = [:]
    private let popUpAPIUseCase = PopUpAPIUseCaseImpl(
        repository: PopUpAPIRepositoryImpl(provider: ProviderImpl()))
    var clusteringManager = ClusteringManager()
    var currentStores: [MapPopUpStore] = []
    var disposeBag = DisposeBag()
    let mainView = MapView()
    let carouselView = MapPopupCarouselView()
    private let locationManager = CLLocationManager()
    var currentMarker: NMFMarker?
    private let storeListReactor = StoreListReactor()
    var storeListViewController = StoreListViewController(reactor: StoreListReactor())
    var listViewTopConstraint: Constraint?
    private var currentFilterBottomSheet: FilterBottomSheetViewController?
    private var filterChipsTopY: CGFloat = 0
    var filterContainerBottomY: CGFloat {
        let frameInView = mainView.filterChips.convert(mainView.filterChips.bounds, to: view)
        return frameInView.maxY
    }

    enum ModalState {
        case top
        case middle
        case bottom
    }

    var modalState: ModalState = .bottom
    private let idleSubject = PublishSubject<Void>()

    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            let frameInView = self.mainView.filterChips.convert(self.mainView.filterChips.bounds, to: self.view)
            self.filterChipsTopY = frameInView.minY
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        mainView.mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mainView.mapView.positionMode = .compass
        checkLocationAuthorization()

        if let reactor = self.reactor {
            reactor.action.onNext(.fetchCategories)

            let koreaRegion = (
                northEast: NMGLatLng(lat: 38.0, lng: 132.0),
                southWest: NMGLatLng(lat: 33.0, lng: 124.0)
            )

            reactor.action.onNext(.viewportChanged(
                northEastLat: koreaRegion.northEast.lat,
                northEastLon: koreaRegion.northEast.lng,
                southWestLat: koreaRegion.southWest.lat,
                southWestLon: koreaRegion.southWest.lng
            ))
        }

        setupMapViewRxObservables()

        carouselView.rx.observe(Bool.self, "hidden")
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isHidden in
                guard let self = self, let isHidden = isHidden else { return }
                self.mainView.setStoreCardHidden(isHidden, animated: true)
            })
            .disposed(by: disposeBag)

        carouselView.onCardTapped = { [weak self] store in
            let detailController = DetailController()
            detailController.reactor = DetailReactor(popUpID: Int64(store.id))

            self?.navigationController?.isNavigationBarHidden = false
            self?.navigationController?.tabBarController?.tabBar.isHidden = false

            self?.navigationController?.pushViewController(detailController, animated: true)
        }

        carouselView.onCardScrolled = { [weak self] pageIndex in
            guard let self = self,
                  pageIndex >= 0,
                  pageIndex < self.currentCarouselStores.count else { return }

            let store = self.currentCarouselStores[pageIndex]

            // 이전 선택 마커 상태 초기화
            if let previousMarker = self.currentMarker {
                self.updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false, count: 1)
            }

            // 스와이프한 스토어에 해당하는 마커 찾기
            let markerToFocus = self.findMarkerForStore(for: store)

            if let markerToFocus = markerToFocus {
                // 마커 선택 상태로 업데이트
                self.updateMarkerStyle(marker: markerToFocus, selected: true, isCluster: false, count: 1)
                self.currentMarker = markerToFocus

                // 마이크로 클러스터인 경우 툴팁 처리
                let userData = markerToFocus.userInfo["storeData"] as? [MapPopUpStore]
                if let storeArray = userData, storeArray.count > 1 {
                    if self.currentTooltipView == nil ||
                       self.currentTooltipCoordinate?.lat != markerToFocus.position.lat ||
                       self.currentTooltipCoordinate?.lng != markerToFocus.position.lng {
                        self.configureTooltip(for: markerToFocus, stores: storeArray)
                    }

                    // 툴팁에서 선택된 스토어 업데이트
                    if let tooltipIndex = storeArray.firstIndex(where: { $0.id == store.id }) {
                        (self.currentTooltipView as? MarkerTooltipView)?.selectStore(at: tooltipIndex)
                    }
                } else {
                    // 단일 마커면 기존 툴팁 제거
                    self.currentTooltipView?.removeFromSuperview()
                    self.currentTooltipView = nil
                }
            }
        }

        if let reactor = self.reactor {
            bindViewport(reactor: reactor)
            reactor.action.onNext(.fetchCategories)
        }
    }

    // NMF 이벤트 설정을 위한 새로운 메서드
    private func setupMapViewRxObservables() {
        // 지도 이동 완료 감지
        mainView.mapView.addCameraDelegate(delegate: self)

        idleSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if let marker = self.currentMarker,
                   let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore],
                   storeArray.count > 1 {
                    if self.currentTooltipView == nil {
                        self.configureTooltip(for: marker, stores: storeArray)
                    } else {
                        self.updateTooltipPosition()
                    }
                }
                self.isMovingToMarker = false
            })
            .disposed(by: disposeBag)
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
        carouselView.isHidden = true
        mainView.mapView.touchDelegate = self

        addChild(storeListViewController)
        view.addSubview(storeListViewController.view)
        storeListViewController.didMove(toParent: self)

        storeListViewController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            listViewTopConstraint = make.top.equalToSuperview().offset(view.frame.height).constraint
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        storeListViewController.mainView.grabberHandle.addGestureRecognizer(panGesture)
        storeListViewController.mainView.addGestureRecognizer(panGesture)
        setupPanAndSwipeGestures()

        let mapViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapViewTap(_:)))
        mapViewTapGesture.delaysTouchesBegan = false
        mainView.mapView.addGestureRecognizer(mapViewTapGesture)
        mapViewTapGesture.delegate = self
    }

    private let defaultZoomLevel: Double = 15.0
    private func setupPanAndSwipeGestures() {
        storeListViewController.mainView.grabberHandle.rx.swipeGesture(.up)
            .skip(1)
            .withUnretained(self)
            .subscribe { owner, _ in
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
                owner.animateToState(.middle)
            }
            .disposed(by: disposeBag)

        // 위치 버튼
        mainView.locationButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self,
                      let location = self.locationManager.location else { return }

                // 현재 위치로 카메라 이동
                let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude
                ), zoomTo: 15.0)

                self.mainView.mapView.moveCamera(cameraUpdate)
            }
            .disposed(by: disposeBag)

        mainView.filterChips.onRemoveLocation = { [weak self] in
            guard let self = self else { return }
            // 필터 제거 액션
            self.reactor?.action.onNext(.clearFilters(.location))

            // 현재 뷰포트의 바운드로 마커 업데이트 요청
            let bounds = self.getVisibleBounds()
            self.reactor?.action.onNext(.viewportChanged(
                northEastLat: bounds.northEast.lat,
                northEastLon: bounds.northEast.lng,
                southWestLat: bounds.southWest.lat,
                southWestLon: bounds.southWest.lng
            ))

            self.clearAllMarkers()
            self.clusterMarkerDictionary.values.forEach { $0.mapView = nil }
            self.clusterMarkerDictionary.removeAll()

            // 캐러셀 숨기기 추가
            self.carouselView.isHidden = true
            self.carouselView.updateCards([])
            self.currentCarouselStores = []
            self.mainView.setStoreCardHidden(true, animated: true)

            self.updateMapWithClustering()
        }

        mainView.filterChips.onRemoveCategory = { [weak self] in
            guard let self = self else { return }
            // 필터 제거 액션
            self.reactor?.action.onNext(.clearFilters(.category))

            let bounds = self.getVisibleBounds()
            self.reactor?.action.onNext(.viewportChanged(
                northEastLat: bounds.northEast.lat,
                northEastLon: bounds.northEast.lng,
                southWestLat: bounds.southWest.lat,
                southWestLon: bounds.southWest.lng
            ))

            self.resetSelectedMarker()
            self.carouselView.isHidden = true
            self.carouselView.updateCards([])
            self.currentCarouselStores = []
            self.mainView.setStoreCardHidden(true, animated: true)
        }

        Observable.combineLatest(
            reactor.state.map { $0.selectedLocationFilters }.distinctUntilChanged(),
            reactor.state.map { $0.selectedCategoryFilters }.distinctUntilChanged()
        ) { locationFilters, categoryFilters -> (String, String) in
            let locationText: String
            if locationFilters.isEmpty {
                locationText = "지역선택"
            } else if locationFilters.count > 1 {
                locationText = "\(locationFilters[0]) 외 \(locationFilters.count - 1)개"
            } else {
                locationText = locationFilters[0]
            }
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

                // 검색 결과 위치로 카메라 이동
                let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
                    lat: store.latitude,
                    lng: store.longitude
                ), zoomTo: 15.0)
                cameraUpdate.animation = .easeIn
                cameraUpdate.animationDuration = 0.3
                self.mainView.mapView.moveCamera(cameraUpdate)

                self.addMarker(for: store)
            }
            .disposed(by: disposeBag)

        mainView.searchInput.rx.tapGesture()
            .when(.recognized)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let searchMainVC = SearchMainController()
                searchMainVC.reactor = SearchMainReactor()
                owner.navigationController?.pushViewController(searchMainVC, animated: true)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.searchResults }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] results in
                guard let self = self else { return }

                self.clearAllMarkers()
                self.storeListViewController.reactor?.action.onNext(.setStores([]))
                self.carouselView.updateCards([])
                self.carouselView.isHidden = true
                self.resetSelectedMarker()  // 추가된 부분

                if results.isEmpty {
                    self.mainView.setStoreCardHidden(true, animated: true)
                    return
                } else {
                    self.mainView.setStoreCardHidden(false, animated: true)
                }

                // 새 결과로 마커 추가 및 업데이트
                self.addMarkers(for: results)

                // 스토어 리스트 업데이트
                let storeItems = results.map { $0.toStoreItem() }
                self.storeListViewController.reactor?.action.onNext(.setStores(storeItems))

                // 캐러셀 업데이트
                self.carouselView.updateCards(results)
                self.carouselView.isHidden = false
                self.currentCarouselStores = results

                // 첫 번째 검색 결과로 지도 이동
                if let firstStore = results.first {
                    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
                        lat: firstStore.latitude,
                        lng: firstStore.longitude
                    ), zoomTo: 15.0)
                    cameraUpdate.animation = .easeIn
                    cameraUpdate.animationDuration = 0.3
                    self.mainView.mapView.moveCamera(cameraUpdate)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - List View Control
    private func toggleListView() {
        UIView.animate(withDuration: 0.3) {
            let middleOffset = -self.view.frame.height * 0.7
            self.listViewTopConstraint?.update(offset: middleOffset)
            self.modalState = .middle
            self.mainView.searchFilterContainer.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }
    }

    // 마커 추가 메서드 (NMFMarker로 변환)
    func addMarker(for store: MapPopUpStore) {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
        marker.userInfo = ["storeData": store]

        // 마커 스타일 설정
        updateMarkerStyle(marker: marker, selected: false, isCluster: false, count: 1)

        // 수정
        marker.touchHandler = { [weak self] overlay in
            guard let self = self,
                  let tappedMarker = overlay as? NMFMarker,
                  let storeData    = tappedMarker.userInfo["storeData"] as? MapPopUpStore
            else { return false }
            return self.handleSingleStoreTap(tappedMarker, store: storeData)
        }

        marker.mapView = mainView.mapView
        markerDictionary[store.id] = marker
    }

    func imageFromView(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }

    // MARK: - Helper: 클러스터용 커스텀 마커 이미지 생성 (MapMarker를 사용)
    func createClusterMarkerImage(regionName: String, count: Int) -> UIImage? {
        let markerView = MapMarker()
        let input = MapMarker.Input(isSelected: false,
                                    isCluster: true,
                                    regionName: regionName,
                                    count: count,
                                    isMultiMarker: false)
        markerView.injection(with: input)
        if markerView.frame == .zero {
            markerView.frame = CGRect(x: 0, y: 0, width: 80, height: 32)
        }
        return imageFromView(markerView)
    }
        // MARK: - Clustering
        private func clearAllMarkers() {
            individualMarkerDictionary.values.forEach { $0.mapView = nil }
            individualMarkerDictionary.removeAll()

            clusterMarkerDictionary.values.forEach { $0.mapView = nil }
            clusterMarkerDictionary.removeAll()

            markerDictionary.values.forEach { $0.mapView = nil }
            markerDictionary.removeAll()
        }

        func groupStoresByExactLocation(_ stores: [MapPopUpStore]) -> [CoordinateKey: [MapPopUpStore]] {
            var dict = [CoordinateKey: [MapPopUpStore]]()
            for store in stores {
                let key = CoordinateKey(latitude: store.latitude, longitude: store.longitude)
                dict[key, default: []].append(store)
            }
            return dict
        }

        private func updateIndividualMarkers(_ stores: [MapPopUpStore]) {
            var newMarkerIDs = Set<Int64>()

            for store in stores {
                newMarkerIDs.insert(store.id)
                if let marker = individualMarkerDictionary[store.id] {
                    if marker.position.lat != store.latitude || marker.position.lng != store.longitude {
                        marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                    }
                } else {
                    // 새 마커 생성 및 추가
                    let marker = NMFMarker()
                    marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                    marker.userInfo = ["storeData": store]

                    updateMarkerStyle(marker: marker, selected: false, isCluster: false)
                    marker.mapView = mainView.mapView

                    individualMarkerDictionary[store.id] = marker
                }
            }
            for (id, marker) in individualMarkerDictionary {
                if !newMarkerIDs.contains(id) {
                    marker.mapView = nil
                    individualMarkerDictionary.removeValue(forKey: id)
                }
            }
        }

    private func updateClusterMarkers(_ clusters: [ClusterMarkerData]) {
        for clusterData in clusters {
            let clusterKey = clusterData.cluster.name
            let fixedCoordinate = clusterData.cluster.coordinate

            if let marker = clusterMarkerDictionary[clusterKey] {
                if marker.position.lat != fixedCoordinate.lat || marker.position.lng != fixedCoordinate.lng {
                    marker.position = NMGLatLng(lat: fixedCoordinate.lat, lng: fixedCoordinate.lng)
                }
            } else {
                let marker = NMFMarker()
                marker.position = NMGLatLng(lat: fixedCoordinate.lat, lng: fixedCoordinate.lng)
                marker.userInfo = ["clusterData": clusterData]

                updateMarkerStyle(marker: marker, selected: false, isCluster: true,
                                 count: clusterData.storeCount, regionName: clusterData.cluster.name)
                marker.mapView = mainView.mapView

                clusterMarkerDictionary[clusterKey] = marker
            }
        }
    }

        func presentFilterBottomSheet(for filterType: FilterType) {
            guard let reactor = self.reactor else { return }

            let sheetReactor = FilterBottomSheetReactor(
                savedSubRegions: reactor.currentState.selectedLocationFilters,
                savedCategories: reactor.currentState.selectedCategoryFilters
            )
            let viewController = FilterBottomSheetViewController(reactor: sheetReactor)

            let initialIndex = (filterType == .location) ? 0 : 1
            viewController.containerView.segmentedControl.selectedSegmentIndex = initialIndex
            sheetReactor.action.onNext(.segmentChanged(initialIndex))

            viewController.onSave = { [weak self] filterData in
                guard let self = self else { return }
                self.reactor?.action.onNext(.updateBothFilters(
                    locations: filterData.locations,
                    categories: filterData.categories
                ))
                self.reactor?.action.onNext(.filterTapped(nil))

                let bounds = self.getVisibleBounds()
                self.reactor?.action.onNext(.viewportChanged(
                    northEastLat: bounds.northEast.lat,
                    northEastLon: bounds.northEast.lng,
                    southWestLat: bounds.southWest.lat,
                    southWestLon: bounds.southWest.lng
                ))
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

    private func addMarkers(for stores: [MapPopUpStore]) {
        markerDictionary.values.forEach { $0.mapView = nil }
        markerDictionary.removeAll()

        for store in stores {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
            marker.userInfo = ["storeData": store]

            updateMarkerStyle(marker: marker, selected: false, isCluster: false)
            marker.touchHandler = { [weak self] overlay in
                guard let self = self,
                      let tappedMarker = overlay as? NMFMarker,
                      let storeData    = tappedMarker.userInfo["storeData"] as? MapPopUpStore
                else { return false }
                return self.handleSingleStoreTap(tappedMarker, store: storeData)
            }
            marker.mapView = mainView.mapView
            markerDictionary[store.id] = marker
        }
    }
        private func updateListView(with results: [MapPopUpStore]) {
            let storeItems = results.map { $0.toStoreItem() }
            storeListViewController.reactor?.action.onNext(.setStores(storeItems))
        }

        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        private func getEffectiveViewport() -> NMGLatLngBounds {
            let bounds = getVisibleBounds()

            if carouselView.isHidden {
                return NMGLatLngBounds(southWest: bounds.southWest, northEast: bounds.northEast)
            }

            let carouselTopY = carouselView.frame.minY
            let leftPoint = CGPoint(x: 0, y: carouselTopY)
            let rightPoint = CGPoint(x: view.frame.width, y: carouselTopY)

            let leftCoordinate = mainView.mapView.projection.latlng(from: leftPoint)
            let rightCoordinate = mainView.mapView.projection.latlng(from: rightPoint)

            let adjustedSouthWest = NMGLatLng(
                lat: max(leftCoordinate.lat, rightCoordinate.lat),
                lng: bounds.southWest.lng
            )

            return NMGLatLngBounds(
                southWest: adjustedSouthWest,
                northEast: bounds.northEast
            )
        }

        // MARK: - Location
        private func checkLocationAuthorization() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                mainView.mapView.positionMode = .direction
            case .denied, .restricted:
                Logger.log(
                    message: "위치 서비스가 비활성화되었습니다. 설정에서 권한을 확인해주세요.",
                    category: .error
                )
                mainView.mapView.positionMode = .disabled
            @unknown default:
                break
            }
        }

        private func resetSelectedMarker() {
            if let currentMarker = currentMarker {
                // 마커 스타일 업데이트
                updateMarkerStyle(marker: currentMarker, selected: false, isCluster: false)
            }

            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil
            currentTooltipStores = []
            currentTooltipCoordinate = nil
            carouselView.isHidden = true
            carouselView.updateCards([])
            currentCarouselStores = []

            // 현재 마커 참조 제거
            self.currentMarker = nil
        }

        private func findMarkerForStore(for store: MapPopUpStore) -> NMFMarker? {
            for marker in individualMarkerDictionary.values {
                if let singleStore = marker.userInfo["storeData"] as? MapPopUpStore, singleStore.id == store.id {
                    return marker
                }
                if let storeGroup = marker.userInfo["storeData"] as? [MapPopUpStore],
                   storeGroup.contains(where: { $0.id == store.id }) {
                    return marker
                }
            }
            // 상세 레벨이 아닐 경우 clusterMarkerDictionary에도 동일하게 검색
            for marker in clusterMarkerDictionary.values {
                if let clusterData = marker.userInfo["clusterData"] as? ClusterMarkerData,
                   clusterData.cluster.stores.contains(where: { $0.id == store.id }) {
                    return marker
                }
            }
            return nil
        }

        func fetchStoreDetails(for stores: [MapPopUpStore]) {
            guard !stores.isEmpty else { return }

            // 먼저 기본 정보로 StoreItem 생성하여 순서 유지
            let initialStoreItems = stores.map { store in
                StoreItem(
                    id: store.id,
                    thumbnailURL: store.mainImageUrl ?? "",
                    category: store.category,
                    title: store.name,
                    location: store.address,
                    dateRange: "\(store.startDate ?? "") ~ \(store.endDate ?? "")",
                    isBookmarked: false
                )
            }

            // 리스트에는 모든 스토어 정보 표시 (필터링된 모든 스토어)
            self.storeListViewController.reactor?.action.onNext(.setStores(initialStoreItems))

            stores.forEach { store in
                self.popUpAPIUseCase.getPopUpDetail(
                    commentType: "NORMAL",
                    popUpStoredId: store.id
                )
                .asObservable()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] detail in
                    self?.storeListViewController.reactor?.action.onNext(.updateStoreBookmark(
                        id: store.id,
                        isBookmarked: detail.bookmarkYn
                    ))
                })
                .disposed(by: disposeBag)
            }
        }

        func bindViewport(reactor: MapReactor) {
            let cameraObservable = PublishSubject<Void>()
            cameraObservable
                .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
                .map { [unowned self] _ -> MapReactor.Action in
                    let bounds = self.getVisibleBounds()
                    return .viewportChanged(
                        northEastLat: bounds.northEast.lat,
                        northEastLon: bounds.northEast.lng,
                        southWestLat: bounds.southWest.lat,
                        southWestLon: bounds.southWest.lng
                    )
                }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)

            reactor.state
                   .map { $0.viewportStores }
                   .distinctUntilChanged()
                   .filter { !$0.isEmpty }
                   .take(1)
                   .observe(on: MainScheduler.instance)
                   .subscribe(onNext: { [weak self] stores in
                       guard let self = self else { return }

                       // 현재 위치가 있으면 가장 가까운 스토어, 없으면 첫 번째 스토어 표시
                       if let location = self.locationManager.location {
                           self.findAndShowNearestStore(from: location)
                       } else if let firstStore = stores.first,
                                 let marker = self.findMarkerForStore(for: firstStore) {
                           _ = self.handleSingleStoreTap(marker, store: firstStore)
                       }

                       // 현재 스토어 목록 업데이트 및 클러스터링
                       self.currentStores = stores
                       self.updateMapWithClustering()
                   })
                   .disposed(by: disposeBag)

            // 뷰포트 내 마커 업데이트 및 캐러셀 표시
            reactor.state
                .map { $0.viewportStores }
                .distinctUntilChanged()
                .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] stores in
                    guard let self = self else { return }

                    let effectiveViewport = self.getEffectiveViewport()
                    let bounds = self.getVisibleBounds()

                    // 화면에 보이는 스토어만 필터링
                    let visibleStores = stores.filter { store in
                        let storePosition = NMGLatLng(lat: store.latitude, lng: store.longitude)
                        return NMGLatLngBounds(southWest: bounds.southWest, northEast: bounds.northEast).contains(storePosition)
                    }
                    self.currentStores = visibleStores

                    // 개별 마커 레벨인지 확인
                    let currentZoom = self.mainView.mapView.zoomLevel
                    let level = MapZoomLevel.getLevel(from: Float(currentZoom))

                    if level == .detailed && !visibleStores.isEmpty {
                        // 캐러셀에 모든 마커 정보 표시
                        let effectiveStores = visibleStores.filter { store in
                            let storePosition = NMGLatLng(lat: store.latitude, lng: store.longitude)
                            return effectiveViewport.contains(storePosition)
                        }

                        self.currentCarouselStores = visibleStores
                        self.carouselView.updateCards(visibleStores)
                        self.carouselView.isHidden = false
                        self.mainView.setStoreCardHidden(false, animated: true)

                        // 현재 선택된 마커가 있으면 해당 위치로 스크롤
                        if let currentMarker = self.currentMarker {
                            // 마커의 스토어 정보 체크
                            if let currentStore = currentMarker.userInfo["storeData"] as? MapPopUpStore,
                               let index = visibleStores.firstIndex(where: { $0.id == currentStore.id }) {
                                self.carouselView.scrollToCard(index: index)
                            } else if let storeArray = currentMarker.userInfo["storeData"] as? [MapPopUpStore],
                                      let firstStore = storeArray.first,
                                      let index = visibleStores.firstIndex(where: { $0.id == firstStore.id }) {
                                self.carouselView.scrollToCard(index: index)
                            } else {
                                // 선택된 마커가 현재 뷰포트에 없는 경우
                                self.updateMarkerStyle(marker: currentMarker, selected: false, isCluster: false)
                                self.currentMarker = nil

                                // 첫 번째 스토어의 마커를 선택 상태로 설정
                                if let firstStore = visibleStores.first,
                                   let marker = self.findMarkerForStore(for: firstStore) {
                                    self.updateMarkerStyle(marker: marker, selected: true, isCluster: false)
                                    self.currentMarker = marker
                                }

                                self.carouselView.scrollToCard(index: 0)
                            }
                        } else {
                            // 선택된 마커가 없는 경우, 첫 번째 스토어로 설정
                            if let firstStore = visibleStores.first,
                               let marker = self.findMarkerForStore(for: firstStore) {
                                self.updateMarkerStyle(marker: marker, selected: true, isCluster: false)
                                self.currentMarker = marker
                            }
                            self.carouselView.scrollToCard(index: 0)
                        }
                    } else {
                        // 클러스터 레벨이거나 마커가 없는 경우
                        self.carouselView.isHidden = true
                        self.carouselView.updateCards([])
                        self.currentCarouselStores = []
                        self.mainView.setStoreCardHidden(true, animated: true)

                        if level == .detailed && visibleStores.isEmpty {
                            // 개별 마커 레벨인데 마커가 없는 경우 토스트 표시
                            self.showNoMarkersToast()
                        }
                    }

                    self.updateMapWithClustering()
                })
                .disposed(by: disposeBag)
        }

    private func findAndShowNearestStore(from location: CLLocation) {
            guard !currentStores.isEmpty else {
                return
            }

            resetSelectedMarker()

        let nearestStore = currentStores.min { store1, store2 in
            let location1 = CLLocation(latitude: store1.latitude, longitude: store1.longitude)
            let location2 = CLLocation(latitude: store2.latitude, longitude: store2.longitude)
            return location.distance(from: location1) < location.distance(from: location2)
        }

            if let store = nearestStore, let marker = findMarkerForStore(for: store) {
                _ = handleSingleStoreTap(marker, store: store)
            }
            // 마커가 없다면 새로 생성
            else if let store = nearestStore {
                let marker = NMFMarker()
                marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                marker.userInfo = ["storeData": store]
                marker.anchor = CGPoint(x: 0.5, y: 1.0)

                // 마커 스타일 설정
                updateMarkerStyle(marker: marker, selected: true, isCluster: false)
                marker.mapView = mainView.mapView

                individualMarkerDictionary[store.id] = marker
                currentMarker = marker
                carouselView.updateCards([store])
                currentCarouselStores = [store]
                carouselView.scrollToCard(index: 0)
                mainView.setStoreCardHidden(false, animated: true)
            }
        }

    }

    // MARK: - CLLocationManagerDelegate
    extension MapViewController {
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }

            currentMarker?.mapView = nil
            currentMarker = nil
            carouselView.isHidden = true
            currentCarouselStores = []

            let position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: position, zoomTo: 15.0)
            mainView.mapView.moveCamera(cameraUpdate) { [weak self] _ in
                guard let self = self else { return }
                self.findAndShowNearestStore(from: location)
            }

            locationManager.stopUpdatingLocation()
        }
    }

    // MARK: - NMFMapViewTouchDelegate
    extension MapViewController {
        // 마커 탭 이벤트 처리
        func mapView(_ mapView: NMFMapView, didTap marker: NMFMarker) -> Bool {

            // 클러스터 마커 확인
            if let clusterData = marker.userInfo["clusterData"] as? ClusterMarkerData {
                return handleRegionalClusterTap(marker, clusterData: clusterData)
            }
            // 마이크로 클러스터 또는 단일 스토어 마커 확인
            else if let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore] {
                if storeArray.count > 1 {
                    return handleMicroClusterTap(marker, storeArray: storeArray)
                } else if let singleStore = storeArray.first {
                    return handleSingleStoreTap(marker, store: singleStore)
                }
            }
            // 단일 스토어 마커 (배열이 아닌 경우) 확인
            else if let singleStore = marker.userInfo["storeData"] as? MapPopUpStore {
                return handleSingleStoreTap(marker, store: singleStore)
            }

            return false
        }

        // 지도 탭 이벤트 처리
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            guard !isMovingToMarker else { return }

            // 선택된 마커 초기화
            if let currentMarker = currentMarker {
                updateMarkerStyle(marker: currentMarker, selected: false, isCluster: false)
                self.currentMarker = nil
            }

            // 툴팁 제거
            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil
            currentTooltipStores = []
            currentTooltipCoordinate = nil

            // 캐러셀 초기화
            carouselView.isHidden = true
            carouselView.updateCards([])
            self.currentCarouselStores = []
            mainView.setStoreCardHidden(true, animated: true)

            // 클러스터링 업데이트
            updateMapWithClustering()
        }
    }

    // MARK: - NMFMapViewCameraDelegate
    extension MapViewController {
        // 카메라 이동 시작 시 호출
        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            if reason == NMFMapChangedByGesture && !isMovingToMarker {
                resetSelectedMarker()
            }
        }

        // 카메라 이동 중 호출
        func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
            if !isMovingToMarker {
                currentTooltipView?.removeFromSuperview()
                currentTooltipView = nil
                currentTooltipStores = []
                updateMapWithClustering()

                // 캐러셀 초기화
                carouselView.isHidden = true
                carouselView.updateCards([])
                currentCarouselStores = []
            }
        }

        // 카메라 이동 완료 시 호출
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            if let marker = self.currentMarker,
               let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore],
               storeArray.count > 1 {
                // 툴팁이 없으면 생성, 있으면 위치 업데이트
                if self.currentTooltipView == nil {
                    self.configureTooltip(for: marker, stores: storeArray)
                } else {
                    self.updateTooltipPosition()
                }
            }
            self.isMovingToMarker = false

            // 뷰포트 변경 이벤트 처리 - idleSubject 통해 알림
            idleSubject.onNext(())

            // 뷰포트 변경 이벤트 처리
            if let reactor = self.reactor {
                let bounds = self.getVisibleBounds()
                reactor.action.onNext(.viewportChanged(
                    northEastLat: bounds.northEast.lat,
                    northEastLon: bounds.northEast.lng,
                    southWestLat: bounds.southWest.lat,
                    southWestLon: bounds.southWest.lng
                ))
            }
        }
    }

    // MARK: - UIGestureRecognizerDelegate
    extension MapViewController {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // 맵의 내장 제스처와 동시 인식 허용
            return true
        }

        // 리스트뷰가 보일 때만 커스텀 탭 제스처 허용
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            let touchPoint = touch.location(in: view)

            // 리스트뷰가 보이고 터치가 리스트뷰 위에 있으면 탭 처리하지 않음
            if modalState != .bottom {
                let listViewY = storeListViewController.view.frame.minY
                if touchPoint.y > listViewY {
                    return false
                }
            }

            return true
        }
    }
extension NMGLatLngBounds {
    func contains(_ point: NMGLatLng) -> Bool {
        let southWestLat = self.southWest.lat
        let southWestLng = self.southWest.lng
        let northEastLat = self.northEast.lat
        let northEastLng = self.northEast.lng

        return point.lat >= southWestLat &&
               point.lat <= northEastLat &&
               point.lng >= southWestLng &&
               point.lng <= northEastLng
    }
}
