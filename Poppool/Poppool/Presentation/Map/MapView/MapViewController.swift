import UIKit
import FloatingPanel
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import NMapsMap
import CoreLocation
import RxGesture

class MapViewController: BaseViewController, View, CLLocationManagerDelegate, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate, UIGestureRecognizerDelegate {
    typealias Reactor = MapReactor

    fileprivate struct CoordinateKey: Hashable {
        let lat: Int
        let lng: Int

        init(latitude: Double, longitude: Double) {
            self.lat = Int(latitude * 1_000_00)
            self.lng = Int(longitude * 1_000_00)
        }
    }

    var currentTooltipView: UIView?
    var currentTooltipStores: [MapPopUpStore] = []
    var currentTooltipCoordinate: NMGLatLng?

    // MARK: - Properties
    private var storeDetailsCache: [Int64: StoreItem] = [:]
    var isMovingToMarker = false
    var currentCarouselStores: [MapPopUpStore] = []
    private var markerDictionary: [Int64: NMFMarker] = [:]
    private var individualMarkerDictionary: [Int64: NMFMarker] = [:]
    private var clusterMarkerDictionary: [String: NMFMarker] = [:]
    private let popUpAPIUseCase = PopUpAPIUseCaseImpl(
        repository: PopUpAPIRepositoryImpl(provider: ProviderImpl()))
    private let clusteringManager = ClusteringManager()
    var currentStores: [MapPopUpStore] = []
    var disposeBag = DisposeBag()
    let mainView = MapView()
    let carouselView = MapPopupCarouselView()
    private let locationManager = CLLocationManager()
    var currentMarker: NMFMarker?
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

            // 한국 전체 영역에 대한 경계값 설정
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

    private func configureTooltip(for marker: NMFMarker, stores: [MapPopUpStore]) {
        Logger.log(message: """
            툴팁 설정:
            - 현재 캐러셀 스토어: \(currentCarouselStores.map { $0.name })
            - 마커 스토어: \(stores.map { $0.name })
            """, category: .debug)

        // 기존 툴팁 제거
        self.currentTooltipView?.removeFromSuperview()

        let tooltipView = MarkerTooltipView()
        tooltipView.configure(with: stores)

        tooltipView.selectStore(at: 0)

        tooltipView.onStoreSelected = { [weak self] index in
            guard let self = self, index < stores.count else { return }
            self.currentCarouselStores = stores
            self.carouselView.updateCards(stores)
            self.carouselView.scrollToCard(index: index)

            self.updateMarkerStyle(marker: marker, selected: true, isCluster: false, count: stores.count)
            tooltipView.selectStore(at: index)

            Logger.log(message: """
                툴팁 선택:
                - 선택된 스토어: \(stores[index].name)
                - 툴팁 인덱스: \(index)
                """, category: .debug)
        }

        let markerPoint = self.mainView.mapView.projection.point(from: marker.position)
        let markerHeight: CGFloat = 32

        tooltipView.frame = CGRect(
            x: markerPoint.x,
            y: markerPoint.y - markerHeight - tooltipView.frame.height - 14,
            width: tooltipView.frame.width,
            height: tooltipView.frame.height
        )

        self.mainView.addSubview(tooltipView)
        self.currentTooltipView = tooltipView
        self.currentTooltipStores = stores
        self.currentTooltipCoordinate = marker.position
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
//        mapViewTapGesture.cancelsTouchesInView = false  // 중요: 다른 터치 이벤트를 방해하지 않음
        mapViewTapGesture.delaysTouchesBegan = false    // 터치 지연 없음
        mainView.mapView.addGestureRecognizer(mapViewTapGesture)
        mapViewTapGesture.delegate = self
    }


    private let defaultZoomLevel: Double = 15.0
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
                owner.animateToState(.middle) // 버튼 눌렀을 때 상태를 middle로 변경
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

            // 현재 뷰포트의 바운드로 마커 업데이트 요청
            let bounds = self.getVisibleBounds()
            self.reactor?.action.onNext(.viewportChanged(
                northEastLat: bounds.northEast.lat,
                northEastLon: bounds.northEast.lng,
                southWestLat: bounds.southWest.lat,
                southWestLon: bounds.southWest.lng
            ))

            self.resetSelectedMarker()

            // 만약 지도 위 마커를 전부 제거 (상황에 따라)
            // self.clearAllMarkers()
            // self.clusterMarkerDictionary.values.forEach { $0.mapView = nil }
            // self.clusterMarkerDictionary.removeAll()
            self.carouselView.isHidden = true
            self.carouselView.updateCards([])
            self.currentCarouselStores = []
            self.mainView.setStoreCardHidden(true, animated: true)
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
                print("tapGesture fired - push 시작")
                let searchMainVC = SearchMainController()
                searchMainVC.reactor = SearchMainReactor()
                owner.navigationController?.pushViewController(searchMainVC, animated: true)
                print("pushViewController 호출 완료")
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.searchResults }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] results in
                guard let self = self else { return }

                // 이전 선택된 마커, 툴팁, 캐러셀 초기화
                self.clearAllMarkers()
                self.storeListViewController.reactor?.action.onNext(.setStores([]))
                self.carouselView.updateCards([])
                self.carouselView.isHidden = true
                self.resetSelectedMarker()  // 추가된 부분

                // 결과가 없으면 스토어 카드 숨김 후 종료
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

        // 중요: 마커에 직접 터치 핸들러 추가
        marker.touchHandler = { [weak self] (overlay) -> Bool in
            guard let self = self else { return false }

            Logger.log(message: "마커 터치됨! 위치: \(marker.position), 스토어: \(store.name)", category: .debug)

            // 단일 스토어 마커 처리
            return self.handleSingleStoreTap(marker, store: store)
        }

        marker.mapView = mainView.mapView
        markerDictionary[store.id] = marker
    }


    func updateMarkerStyle(marker: NMFMarker, selected: Bool, isCluster: Bool, count: Int = 1, regionName: String = "") {
        if selected {
            marker.width = 44
            marker.height = 44
            marker.iconImage = NMFOverlayImage(name: "TapMarker")
        } else if isCluster {
            marker.width = 36
            marker.height = 36
            marker.iconImage = NMFOverlayImage(name: "cluster_marker")
        } else {
            marker.width = 32
            marker.height = 32
            marker.iconImage = NMFOverlayImage(name: "Marker")
        }

        if count > 1 {
            marker.captionText = "\(count)"
        } else {
            marker.captionText = ""
        }

        marker.anchor = CGPoint(x: 0.5, y: 1.0)
    }

    @objc private func handleMapViewTap(_ gesture: UITapGestureRecognizer) {
        // 리스트뷰가 현재 보이는 상태(중간 또는 상단)일 때만 내림
        if modalState == .middle || modalState == .top {
            Logger.log(message: "맵뷰 탭 감지: 리스트뷰 내림", category: .debug)
            animateToState(.bottom)
        }
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

                animateToState(targetState)
            }

        default:
            break
        }
    }

    private func adjustMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat) {
        let middleOffset = view.frame.height * 0.3

        if offset <= minOffset {
            mainView.mapView.alpha = 0 // 탑에서는 완전히 숨김
        } else if offset >= maxOffset {
            mainView.mapView.alpha = 1 // 바텀에서는 완전히 보임
        } else if offset <= middleOffset {
            let progress = (offset - minOffset) / (middleOffset - minOffset)
            mainView.mapView.alpha = progress
        } else {
            mainView.mapView.alpha = 1
        }
    }

    private func updateMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat) {
        let progress = (maxOffset - offset) / (maxOffset - minOffset)
        mainView.mapView.alpha = max(0, min(progress, 1)) 
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
                let offset = max(self.view.frame.height * 0.3, self.filterContainerBottomY)
                self.listViewTopConstraint?.update(offset: offset)
                self.storeListViewController.mainView.layer.cornerRadius = 20
                self.storeListViewController.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.mainView.mapView.alpha = 1
                self.mainView.mapView.isHidden = false
                self.mainView.searchInput.setBackgroundColor(.white)

                if let reactor = self.reactor {
                    reactor.action.onNext(.fetchAllStores)

                    reactor.state
                        .map { $0.viewportStores }
                        .distinctUntilChanged()
                        .filter { !$0.isEmpty }
                        .take(1)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] stores in
                            guard let self = self else { return }
                            self.fetchStoreDetails(for: stores)

                            Logger.log(
                                message: "✅ 전체 스토어 목록으로 리스트뷰 업데이트: \(stores.count)개",
                                category: .debug
                            )
                        })
                        .disposed(by: self.disposeBag)
                }

            case .bottom:
                self.storeListViewController.setGrabberHandleVisible(true)
                self.listViewTopConstraint?.update(offset: self.view.frame.height)
                self.mainView.mapView.alpha = 1
                self.mainView.mapView.isHidden = false
                self.mainView.searchInput.setBackgroundColor(.white)
            }

            self.view.layoutIfNeeded()
        }) { _ in
            self.modalState = state
            Logger.log(message: ". 현재 상태: \(state)", category: .debug)
        }
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
        // MapMarker의 입력값에 클러스터 상태를 전달합니다.
        let markerView = MapMarker()  // 기존 커스텀 뷰, 네이버맵용으로도 사용 가능하도록 구현됨.
        let input = MapMarker.Input(isSelected: false,
                                    isCluster: true,
                                    regionName: regionName,
                                    count: count,
                                    isMultiMarker: false)
        markerView.injection(with: input)
        // 프레임이 설정되어 있지 않다면 적당한 크기로 지정 (예: 80x32)
        if markerView.frame == .zero {
            markerView.frame = CGRect(x: 0, y: 0, width: 80, height: 32)
        }
        return imageFromView(markerView)
    }
        // MARK: - Clustering
    private func updateMapWithClustering() {
        let currentZoom = mainView.mapView.zoomLevel
        let level = MapZoomLevel.getLevel(from: Float(currentZoom))
        // 클러스터 처리 시 현재 스토어 목록(currentStores)을 사용
        Logger.log(message: "현재 줌 레벨: \(currentZoom), 모드: \(level), 스토어 수: \(currentStores.count)", category: .debug)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        switch level {
        case .detailed:
            // 상세 레벨에서는 개별 마커를 사용합니다.
            let newStoreIds = Set(currentStores.map { $0.id })
            let groupedDict = groupStoresByExactLocation(currentStores)

            // 클러스터 마커 제거
            clusterMarkerDictionary.values.forEach { $0.mapView = nil }
            clusterMarkerDictionary.removeAll()

            // 그룹별로 개별 마커 생성/업데이트
            for (coordinate, storeGroup) in groupedDict {
                if storeGroup.count == 1, let store = storeGroup.first {
                    if let existingMarker = individualMarkerDictionary[store.id] {
                        if existingMarker.position.lat != store.latitude ||
                            existingMarker.position.lng != store.longitude {
                            existingMarker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                        }
                        let isSelected = (existingMarker == currentMarker)
                        updateMarkerStyle(marker: existingMarker, selected: isSelected, isCluster: false)
                    } else {
                        let marker = NMFMarker()
                        marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                        marker.userInfo = ["storeData": store]
                        marker.anchor = CGPoint(x: 0.5, y: 1.0)
                        updateMarkerStyle(marker: marker, selected: false, isCluster: false)

                        // 직접 터치 핸들러 추가
                        marker.touchHandler = { [weak self] (overlay) -> Bool in
                            guard let self = self else { return false }

                            print("개별 마커 터치됨! 스토어: \(store.name)")
                            return self.handleSingleStoreTap(marker, store: store)
                        }

                        marker.mapView = mainView.mapView
                        individualMarkerDictionary[store.id] = marker
                    }
                } else {
                    // 여러 스토어가 동일 위치에 있으면 단일 마커로 표시하면서 count 갱신
                    guard let firstStore = storeGroup.first else { continue }
                    let markerKey = firstStore.id
                    if let existingMarker = individualMarkerDictionary[markerKey] {
                        existingMarker.userInfo = ["storeData": storeGroup]
                        let isSelected = (existingMarker == currentMarker)
                        updateMarkerStyle(marker: existingMarker, selected: isSelected, isCluster: false, count: storeGroup.count)
                    } else {
                        let marker = NMFMarker()
                        marker.position = NMGLatLng(lat: firstStore.latitude, lng: firstStore.longitude)
                        marker.userInfo = ["storeData": storeGroup]
                        marker.anchor = CGPoint(x: 0.5, y: 1.0)
                        updateMarkerStyle(marker: marker, selected: false, isCluster: false, count: storeGroup.count)

                        // 직접 터치 핸들러 추가
                        marker.touchHandler = { [weak self] (overlay) -> Bool in
                            guard let self = self else { return false }

                            print("마이크로 클러스터 마커 터치됨! 스토어 수: \(storeGroup.count)개")
                            return self.handleMicroClusterTap(marker, storeArray: storeGroup)
                        }

                        marker.mapView = mainView.mapView
                        individualMarkerDictionary[markerKey] = marker
                    }
                }
            }

            // 기존에 보이지 않는 개별 마커 제거
            individualMarkerDictionary = individualMarkerDictionary.filter { id, marker in
                if newStoreIds.contains(id) {
                    return true
                } else {
                    marker.mapView = nil
                    return false
                }
            }

        case .district, .city, .country:
            // 개별 마커 숨기기
            individualMarkerDictionary.values.forEach { $0.mapView = nil }
            individualMarkerDictionary.removeAll()

            // 클러스터 생성
            let clusters = clusteringManager.clusterStores(currentStores, at: Float(currentZoom))
            let activeClusterKeys = Set(clusters.map { $0.cluster.name })

            for cluster in clusters {
                let clusterKey = cluster.cluster.name
                var marker: NMFMarker
                if let existingMarker = clusterMarkerDictionary[clusterKey] {
                    marker = existingMarker
                    // 위치 업데이트가 필요하면 수정
                    if marker.position.lat != cluster.cluster.coordinate.lat ||
                        marker.position.lng != cluster.cluster.coordinate.lng {
                        marker.position = NMGLatLng(lat: cluster.cluster.coordinate.lat, lng: cluster.cluster.coordinate.lng)
                    }
                } else {
                    marker = NMFMarker()
                    clusterMarkerDictionary[clusterKey] = marker
                }

                marker.position = NMGLatLng(lat: cluster.cluster.coordinate.lat, lng: cluster.cluster.coordinate.lng)
                marker.userInfo = ["clusterData": cluster]  // 중요: userInfo에 cluster 객체를 직접 저장

                // 여기서 커스텀 클러스터 마커 뷰를 이미지로 변환하여 적용합니다.
                if let clusterImage = createClusterMarkerImage(regionName: cluster.cluster.name, count: cluster.storeCount) {
                    marker.iconImage = NMFOverlayImage(image: clusterImage)
                } else {
                    // 기본 에셋 fallback (원하는 경우)
                    marker.iconImage = NMFOverlayImage(name: "cluster_marker")
                }

                // 터치 핸들러 추가 - userInfo에서 클러스터 데이터를 직접 가져오기
                marker.touchHandler = { [weak self] (overlay) -> Bool in
                    guard let self = self,
                          let tappedMarker = overlay as? NMFMarker,
                          let clusterData = tappedMarker.userInfo["clusterData"] as? ClusterMarkerData else {
                        return false
                    }

                    return self.handleRegionalClusterTap(tappedMarker, clusterData: clusterData)
                }

                marker.captionText = ""
                marker.anchor = CGPoint(x: 0.5, y: 0.5)
                marker.mapView = mainView.mapView
            }

            // 활성 클러스터가 아닌 마커 제거
            for (key, marker) in clusterMarkerDictionary {
                if !activeClusterKeys.contains(key) {
                    marker.mapView = nil
                    clusterMarkerDictionary.removeValue(forKey: key)
                }
            }
        }

        CATransaction.commit()
    }


        private func clearAllMarkers() {
            individualMarkerDictionary.values.forEach { $0.mapView = nil }
            individualMarkerDictionary.removeAll()

            clusterMarkerDictionary.values.forEach { $0.mapView = nil }
            clusterMarkerDictionary.removeAll()

            markerDictionary.values.forEach { $0.mapView = nil }
            markerDictionary.removeAll()
        }

        private func groupStoresByExactLocation(_ stores: [MapPopUpStore]) -> [CoordinateKey: [MapPopUpStore]] {
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

        //기본 마커
    private func addMarkers(for stores: [MapPopUpStore]) {
        markerDictionary.values.forEach { $0.mapView = nil }
        markerDictionary.removeAll()

        for store in stores {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
            marker.userInfo = ["storeData": store]

            updateMarkerStyle(marker: marker, selected: false, isCluster: false)

            // 직접 터치 핸들러 추가
            marker.touchHandler = { [weak self] (overlay) -> Bool in
                guard let self = self else { return false }

                print("검색 결과 마커 터치됨! 스토어: \(store.name)")
                return self.handleSingleStoreTap(marker, store: store)
            }

            marker.mapView = mainView.mapView
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

        // 현재 보이는 지도 영역의 경계를 가져오는 함수
        private func getVisibleBounds() -> (northEast: NMGLatLng, southWest: NMGLatLng) {
            let mapBounds = mainView.mapView.contentBounds

            let northEast = NMGLatLng(lat: mapBounds.northEastLat, lng: mapBounds.northEastLng)
            let southWest = NMGLatLng(lat: mapBounds.southWestLat, lng: mapBounds.southWestLng)

            return (northEast: northEast, southWest: southWest)
        }

        // MARK: - Location
        private func checkLocationAuthorization() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                mainView.mapView.positionMode = .direction  // 내 위치 트래킹 모드 활성화
            case .denied, .restricted:
                Logger.log(
                    message: "위치 서비스가 비활성화되었습니다. 설정에서 권한을 확인해주세요.",
                    category: .error
                )
                mainView.mapView.positionMode = .disabled  // 내 위치 트래킹 모드 비활성화
            @unknown default:
                break
            }
        }

        private func updateTooltipPosition() {
            guard let marker = currentMarker, let tooltip = currentTooltipView else { return }

            // 마커 위치를 화면 좌표로 변환
            let markerPoint = mainView.mapView.projection.point(from: marker.position)
            var markerCenter = markerPoint

            // 마커 높이 고려 (네이버 마커는 크기가 다를 수 있음)
            markerCenter.y = markerPoint.y - 20 // 마커 이미지 높이의 절반 정도

            // 오프셋 값 (디자인에 맞게 조정)
            let offsetX: CGFloat = -10
            let offsetY: CGFloat = -10

            tooltip.frame.origin = CGPoint(
                x: markerCenter.x + offsetX,
                y: markerCenter.y - tooltip.frame.height - offsetY
            )
        }

        private func resetSelectedMarker() {
            if let currentMarker = currentMarker {
                // 마커 스타일 업데이트
                updateMarkerStyle(marker: currentMarker, selected: false, isCluster: false)
            }

            // 툴팁 제거
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

    private func updateMarkersForCluster(stores: [MapPopUpStore]) {
        // 전체 개별 및 클러스터 마커 제거
        for marker in individualMarkerDictionary.values {
            marker.mapView = nil
        }
        individualMarkerDictionary.removeAll()

        for marker in clusterMarkerDictionary.values {
            marker.mapView = nil
        }
        clusterMarkerDictionary.removeAll()

        // 클러스터에 포함된 스토어들만 새 마커 추가
        for store in stores {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
            marker.userInfo = ["storeData": store]
            marker.anchor = CGPoint(x: 0.5, y: 1.0)

            updateMarkerStyle(marker: marker, selected: false, isCluster: false)

            // 직접 터치 핸들러 추가
            marker.touchHandler = { [weak self] (overlay) -> Bool in
                guard let self = self else { return false }

                print("클러스터 내 마커 터치됨! 스토어: \(store.name)")
                return self.handleSingleStoreTap(marker, store: store)
            }

            marker.mapView = mainView.mapView
            individualMarkerDictionary[store.id] = marker
        }
    }


        private func findMarkerForStore(for store: MapPopUpStore) -> NMFMarker? {
            // individualMarkerDictionary에 저장된 모든 마커를 순회
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

        private func fetchStoreDetails(for stores: [MapPopUpStore]) {
            // 빈 목록이면 처리하지 않음
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

            // 각 스토어의 상세 정보를 병렬로 가져와서 업데이트 (북마크 정보 등)
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
            // 카메라 이동 완료 시 이벤트 발생되는 Subject
            let cameraObservable = PublishSubject<Void>()

            // NMFMapViewCameraDelegate 메서드에서 호출할 수 있도록 설정

            // 카메라 변경 감지해서 액션 전달
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

            // 현재 뷰포트 내의 스토어 업데이트 - 초기 1회
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
                Logger.log(message: "현재위치 표기할 스토어가 없습니다", category: .debug)
                return
            }

            resetSelectedMarker()

        let nearestStore = currentStores.min { store1, store2 in
            let location1 = CLLocation(latitude: store1.latitude, longitude: store1.longitude)
            let location2 = CLLocation(latitude: store2.latitude, longitude: store2.longitude)
            return location.distance(from: location1) < location.distance(from: location2)
        }

            if let store = nearestStore, let marker = findMarkerForStore(for: store) {
                // 카메라 이동 없이 선택된 마커만 업데이트
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

        // MARK: - Marker Handling
        func handleSingleStoreTap(_ marker: NMFMarker, store: MapPopUpStore) -> Bool {
            isMovingToMarker = true

            // 이전 마커 선택 상태 해제
            if let previousMarker = currentMarker {
                updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
            }

            // 새 마커 선택 상태로 설정
            updateMarkerStyle(marker: marker, selected: true, isCluster: false)
            currentMarker = marker

            // 캐러셀에 표시할 스토어 확인
            if currentCarouselStores.isEmpty || !currentCarouselStores.contains(where: { $0.id == store.id }) {
                // 현재 뷰포트의 모든 스토어를 가져오기
                let bounds = getVisibleBounds()

                let visibleStores = currentStores.filter { store in
                    let storePosition = NMGLatLng(lat: store.latitude, lng: store.longitude)
                    return NMGLatLngBounds(southWest: bounds.southWest, northEast: bounds.northEast).contains(storePosition)
                }

                if !visibleStores.isEmpty {
                    // 뷰포트의 모든 스토어를 캐러셀에 표시
                    currentCarouselStores = visibleStores
                    carouselView.updateCards(visibleStores)

                    // 선택한 스토어의 인덱스를 찾아 스크롤
                    if let index = visibleStores.firstIndex(where: { $0.id == store.id }) {
                        carouselView.scrollToCard(index: index)
                    }
                } else {
                    // 뷰포트에 다른 스토어가 없는 경우, 선택한 스토어만 표시
                    currentCarouselStores = [store]
                    carouselView.updateCards([store])
                }
            } else {
                // 캐러셀에 이미 해당 스토어가 있는 경우, 해당 위치로 스크롤
                if let index = currentCarouselStores.firstIndex(where: { $0.id == store.id }) {
                    carouselView.scrollToCard(index: index)
                }
            }

            carouselView.isHidden = false
            mainView.setStoreCardHidden(false, animated: true)

            // 툴팁 처리
            if let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore], storeArray.count > 1 {
                // 마이크로 클러스터인 경우 툴팁 표시
                configureTooltip(for: marker, stores: storeArray)
                // 해당 스토어의 툴팁 인덱스 선택
                if let index = storeArray.firstIndex(where: { $0.id == store.id }) {
                    (currentTooltipView as? MarkerTooltipView)?.selectStore(at: index)
                }
            } else {
                // 단일 마커인 경우 툴팁 제거
                currentTooltipView?.removeFromSuperview()
                currentTooltipView = nil
            }

            isMovingToMarker = false
            return true
        }

        // 리전 클러스터 탭 처리
    func handleRegionalClusterTap(_ marker: NMFMarker, clusterData: ClusterMarkerData) -> Bool {
        print("handleRegionalClusterTap 함수 호출됨")

        let currentZoom = mainView.mapView.zoomLevel
        let currentLevel = MapZoomLevel.getLevel(from: Float(currentZoom))

        // 디버깅
        print("현재 줌 레벨: \(currentZoom), 모드: \(currentLevel)")
        print("클러스터 정보: \(clusterData.cluster.name), 스토어 수: \(clusterData.storeCount)")

        switch currentLevel {
        case .city:  // 시 단위 클러스터
            print("시 단위 클러스터 처리")
            let districtZoomLevel: Double = 10.0
            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: districtZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
            mainView.mapView.moveCamera(cameraUpdate)

        case .district:  // 구 단위 클러스터
            print("구 단위 클러스터 처리")
            let detailedZoomLevel: Double = 12.0
            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: detailedZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
            mainView.mapView.moveCamera(cameraUpdate)

        default:
            print("기타 레벨 클러스터 처리")
            break
        }

        // 클러스터에 포함된 스토어들만 표시하도록 마커 업데이트
        updateMarkersForCluster(stores: clusterData.cluster.stores)

        // 캐러셀 업데이트
        carouselView.updateCards(clusterData.cluster.stores)
        carouselView.isHidden = false
        self.currentCarouselStores = clusterData.cluster.stores

        return true
    }


        // 마이크로 클러스터 탭 처리
        func handleMicroClusterTap(_ marker: NMFMarker, storeArray: [MapPopUpStore]) -> Bool {
            // 이미 선택된 마커를 다시 탭할 때
            if currentMarker == marker {
                // 툴팁과 캐러셀만 숨기고, 마커의 선택 상태는 유지
                currentTooltipView?.removeFromSuperview()
                currentTooltipView = nil
                currentTooltipStores = []
                currentTooltipCoordinate = nil

                carouselView.isHidden = true
                carouselView.updateCards([])
                currentCarouselStores = []

                // 마커 상태 업데이트
                updateMarkerStyle(marker: marker, selected: false, isCluster: false, count: storeArray.count)

                currentMarker = nil
                isMovingToMarker = false
                return false
            }

            isMovingToMarker = true

            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil

            if let previousMarker = currentMarker {
                updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
            }

            updateMarkerStyle(marker: marker, selected: true, isCluster: false, count: storeArray.count)
            currentMarker = marker

            currentCarouselStores = storeArray
            carouselView.updateCards(storeArray)
            carouselView.isHidden = false
            carouselView.scrollToCard(index: 0)

            mainView.setStoreCardHidden(false, animated: true)

            // 지도 이동
            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
            mainView.mapView.moveCamera(cameraUpdate)

            // 툴팁 생성
            if storeArray.count > 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.configureTooltip(for: marker, stores: storeArray)
                    self.isMovingToMarker = false
                }
            }

            return true
        }

        private func showNoMarkersToast() {
            // 디자인 예정이므로 임시 구현
            Logger.log(message: "현재 지도 영역에 표시할 마커가 없습니다", category: .debug)
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
        // 마커 탭 이벤트 처리
        func mapView(_ mapView: NMFMapView, didTap marker: NMFMarker) -> Bool {
            Logger.log(message: "didTapMarker 호출됨: \(marker.position), userInfo: \(marker.userInfo)", category: .debug)

            // 클러스터 마커 확인
            if let clusterData = marker.userInfo["clusterData"] as? ClusterMarkerData {
                Logger.log(message: "클러스터 데이터 감지: \(clusterData.cluster.name), 스토어 수: \(clusterData.storeCount)", category: .debug)
                return handleRegionalClusterTap(marker, clusterData: clusterData)
            }
            // 마이크로 클러스터 또는 단일 스토어 마커 확인
            else if let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore] {
                if storeArray.count > 1 {
                    Logger.log(message: "마이크로 클러스터 감지: \(storeArray.count)개 스토어", category: .debug)
                    return handleMicroClusterTap(marker, storeArray: storeArray)
                } else if let singleStore = storeArray.first {
                    Logger.log(message: "단일 스토어 감지: \(singleStore.name)", category: .debug)
                    return handleSingleStoreTap(marker, store: singleStore)
                }
            }
            // 단일 스토어 마커 (배열이 아닌 경우) 확인
            else if let singleStore = marker.userInfo["storeData"] as? MapPopUpStore {
                Logger.log(message: "단일 스토어 감지: \(singleStore.name)", category: .debug)
                return handleSingleStoreTap(marker, store: singleStore)
            }

            Logger.log(message: "인식할 수 없는 마커 타입", category: .error)
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
        // 맵뷰의 다른 제스처와 충돌하지 않도록 함
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // 맵의 내장 제스처와 동시 인식 허용
            return true
        }

        // 리스트뷰가 보일 때만 커스텀 탭 제스처 허용
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // 터치가 리스트뷰 영역에 있으면 커스텀 제스처 트리거하지 않음
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
