import CoreLocation
import UIKit

import DesignSystem
import DomainInterface
import Infrastructure
import SearchFeatureInterface

import FloatingPanel
import NMapsMap
import ReactorKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit

class MapViewController: BaseViewController, View {
    // 최초 뷰포트 진입 여부 플래그
    private var isFirstViewportEntry = true
    typealias Reactor = MapReactor

    fileprivate struct CoordinateKey: Hashable {
        let lat: Int
        let lng: Int

        init(latitude: Double, longitude: Double) {
            self.lat = Int(latitude * Constants.coordinateMultiplier)
             self.lng = Int(longitude * Constants.coordinateMultiplier)
        }
    }

    private enum Constants {
        static let carouselHeight: CGFloat        = 140
        static let carouselBottomOffset: CGFloat  = -24
        static let tooltipMarkerHeight: CGFloat   = 32
        static let tooltipYOffset: CGFloat        = 14
        static let coordinateMultiplier: Double   = 100_000
        static let cameraDebounceMs: Int          = 300
        static let swipeDuration: TimeInterval    = 0.3
        static let panVelocityThreshold: CGFloat  = 500
        static let middleRatio: CGFloat           = 0.3
        static let defaultZoom: Double            = 15.0
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
    @Dependency private var popUpAPIUseCase: PopUpAPIUseCase
    private let clusteringManager = ClusteringManager()
    var currentStores: [MapPopUpStore] = []
    var disposeBag = DisposeBag()
    let mainView = MapView()
    let carouselView = MapPopupCarouselView()
    private let locationManager = CLLocationManager()
    var currentMarker: NMFMarker?
    private let storeListReactor = StoreListReactor(
        userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self),
        popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self)
    )
    private let storeListViewController = StoreListViewController(
        reactor: StoreListReactor(
            userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self),
            popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self)
        )
    )
    private var listViewTopConstraint: Constraint?
    private var currentFilterBottomSheet: FilterBottomSheetViewController?
    private var filterChipsTopY: CGFloat = 0
    private var filterContainerBottomY: CGFloat {
        let frameInView = mainView.filterChips.convert(mainView.filterChips.bounds, to: view)
        return frameInView.maxY
    }

    enum ModalState {
        case top
        case middle
        case bottom
    }

    private var modalState: ModalState = .bottom
    private let idleSubject = PublishSubject<Void>()
    private let cameraIdle = PublishSubject<Void>()

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
            detailController.reactor = DetailReactor(
                popUpID: Int64(store.id),
                userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self),
                popUpAPIUseCase: self?.popUpAPIUseCase ?? DIContainer.resolve(PopUpAPIUseCase.self),
                commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
            )

            self?.navigationController?.isNavigationBarHidden = false
            self?.navigationController?.tabBarController?.tabBar.isHidden = false

            self?.navigationController?.pushViewController(detailController, animated: true)
        }

        carouselView.onCardScrolled = { [weak self] pageIndex in
            guard let self = self,
                  pageIndex >= 0,
                  pageIndex < self.currentCarouselStores.count else { return }

            let store = self.currentCarouselStores[pageIndex]
            if let previousMarker = self.currentMarker {
                self.updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false, count: 1)
            }

            let markerToFocus = self.findMarkerForStore(for: store)

            if let markerToFocus = markerToFocus {
                self.updateMarkerStyle(marker: markerToFocus, selected: true, isCluster: false, count: 1)
                self.currentMarker = markerToFocus
                let userData = markerToFocus.userInfo["storeData"] as? [MapPopUpStore]
                if let storeArray = userData, storeArray.count > 1 {
                    if self.currentTooltipView == nil ||
                       self.currentTooltipCoordinate?.lat != markerToFocus.position.lat ||
                       self.currentTooltipCoordinate?.lng != markerToFocus.position.lng {
                        self.configureTooltip(for: markerToFocus, stores: storeArray)
                    }

                    if let tooltipIndex = storeArray.firstIndex(where: { $0.id == store.id }) {
                        (self.currentTooltipView as? MarkerTooltipView)?.selectStore(at: tooltipIndex)
                    }
                } else {
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

    private func setupMapViewRxObservables() {
        mainView.mapView.addCameraDelegate(delegate: self)
        cameraIdle
            .debounce(.milliseconds(Constants.cameraDebounceMs), scheduler: MainScheduler.instance)
            .map { [unowned self] in
                let bounds = self.getVisibleBounds()
                return MapReactor.Action.viewportChanged(
                    northEastLat: bounds.northEast.lat,
                    northEastLon: bounds.northEast.lng,
                    southWestLat: bounds.southWest.lat,
                    southWestLon: bounds.southWest.lng
                )
            }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)

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
        }

        let markerPoint = self.mainView.mapView.projection.point(from: marker.position)
        let markerHeight = Constants.tooltipMarkerHeight
        tooltipView.frame = CGRect(
            x: markerPoint.x,
            y: markerPoint.y - markerHeight - tooltipView.frame.height - Constants.tooltipYOffset,
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
            make.height.equalTo(Constants.carouselHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(Constants.carouselBottomOffset)
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

    private let defaultZoomLevel: Double = Constants.defaultZoom
    private func setupPanAndSwipeGestures() {
        storeListViewController.mainView.grabberHandle.rx.swipeGesture(.up)
            .skip(1)
            .withUnretained(self)
            .subscribe { owner, _ in
                Logger.log("⬆️ 위로 스와이프 감지", category: .debug)
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
                Logger.log("⬇️ 아래로 스와이프 감지됨", category: .debug)
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
        mainView.filterChips.locationChip.rx.tap
            .map { Reactor.Action.filterTapped(.location) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.filterChips.categoryChip.rx.tap
            .map { Reactor.Action.filterTapped(.category) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

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
                let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude
                ), zoomTo: Constants.defaultZoom)

                self.mainView.mapView.moveCamera(cameraUpdate)
            }
            .disposed(by: disposeBag)

        mainView.filterChips.onRemoveLocation = { [weak self] in
            guard let self = self else { return }
            self.reactor?.action.onNext(.clearFilters(.location))
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

            self.carouselView.isHidden = true
            self.carouselView.updateCards([])
            self.currentCarouselStores = []
            self.mainView.setStoreCardHidden(true, animated: true)

            self.updateMapWithClustering()
        }

        mainView.filterChips.onRemoveCategory = { [weak self] in
            guard let self = self else { return }
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

                let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
                    lat: store.latitude,
                    lng: store.longitude
                ), zoomTo: Constants.defaultZoom)
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
                @Dependency var factory: PopupSearchFactory
                owner.navigationController?.pushViewController(factory.make(), animated: true)
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
                self.addMarkers(for: results)
                let storeItems = results.map { store in
                    StoreItem(
                        id: store.id,
                        thumbnailURL: store.mainImageUrl ?? "",
                        category: store.category,
                        title: store.name,
                        location: store.address,
                        dateRange: "\(store.startDate) ~ \(store.endDate)",
                        isBookmarked: false
                    )
                }
                self.storeListViewController.reactor?.action.onNext(.setStores(storeItems))
                self.carouselView.updateCards(results)
                self.carouselView.isHidden = false
                self.currentCarouselStores = results
                if let firstStore = results.first {
                    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
                        lat: firstStore.latitude,
                        lng: firstStore.longitude
                    ), zoomTo: Constants.defaultZoom)
                    cameraUpdate.animation = .easeIn
                    cameraUpdate.animationDuration = 0.3
                    self.mainView.mapView.moveCamera(cameraUpdate)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - List View Control
    private func toggleListView() {
        UIView.animate(withDuration: Constants.swipeDuration) {
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
        marker.touchHandler = { [weak self] (_) -> Bool in
            guard let self = self else { return false }
            // 단일 스토어 마커 처리
            return self.handleSingleStoreTap(marker, store: store)
        }

        marker.mapView = mainView.mapView
        markerDictionary[store.id] = marker
    }

    func updateMarkerStyle(
        marker: NMFMarker,
        selected: Bool,
        isCluster: Bool,
        count: Int = 1,
        regionName: String = ""
    ) {
        let mapMarkerView: MapMarker
        if let cachedView = marker.userInfo["mapMarkerView"] as? MapMarker {
            mapMarkerView = cachedView
        } else {
            mapMarkerView = MapMarker()
            marker.userInfo["mapMarkerView"] = mapMarkerView
        }

        let wasMultiMarker = (mapMarkerView.currentInput?.count ?? 0) > 1

        let input = MapMarker.Input(
            isSelected: selected,
            isCluster: isCluster,
            regionName: regionName,
            count: count,
            isMultiMarker: count > 1 && !isCluster
        )
        mapMarkerView.injection(with: input)

        if let img = mapMarkerView.asImage() {
            marker.iconImage = NMFOverlayImage(image: img)
            marker.width = img.size.width
            marker.height = img.size.height
            marker.anchor = CGPoint(x: 0.5, y: isCluster ? 0.5 : 1.0)
        }
    }

    @objc private func handleMapViewTap(_ gesture: UITapGestureRecognizer) {
        if modalState == .middle || modalState == .top {
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

                let minOffset: CGFloat = filterContainerBottomY
                let maxOffset: CGFloat = view.frame.height
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
                let middleY = view.frame.height * 0.3
                let targetState: ModalState

                if velocity.y > Constants.panVelocityThreshold {
                    targetState = .bottom
                } else if velocity.y < -Constants.panVelocityThreshold {
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
            mainView.mapView.alpha = 0
        } else if offset >= maxOffset {
            mainView.mapView.alpha = 1
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
                self.mainView.mapView.alpha = 0
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
                                "✅ 전체 스토어 목록으로 리스트뷰 업데이트: \(stores.count)개",
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
    private func updateMapWithClustering() {
        let currentZoom = mainView.mapView.zoomLevel
        let level = MapZoomLevel.getLevel(from: Float(currentZoom))
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        switch level {
        case .detailed:
            let newStoreIds = Set(currentStores.map { $0.id })
            let groupedDict = groupStoresByExactLocation(currentStores)
            clusterMarkerDictionary.values.forEach { $0.mapView = nil }
            clusterMarkerDictionary.removeAll()

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
                        marker.touchHandler = { [weak self] (_) -> Bool in
                            guard let self = self else { return false }
                            return self.handleSingleStoreTap(marker, store: store)
                        }

                        marker.mapView = mainView.mapView
                        individualMarkerDictionary[store.id] = marker
                    }
                } else {
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

                        marker.touchHandler = { [weak self] (_) -> Bool in
                            guard let self = self else { return false }
                            return self.handleMicroClusterTap(marker, storeArray: storeGroup)
                        }

                        marker.mapView = mainView.mapView
                        individualMarkerDictionary[markerKey] = marker
                    }
                }
            }

            individualMarkerDictionary = individualMarkerDictionary.filter { id, marker in
                if newStoreIds.contains(id) {
                    return true
                } else {
                    marker.mapView = nil
                    return false
                }
            }

        case .district, .city, .country:
            individualMarkerDictionary.values.forEach { $0.mapView = nil }
            individualMarkerDictionary.removeAll()

            let clusters = clusteringManager.clusterStores(currentStores, at: Float(currentZoom))
            let activeClusterKeys = Set(clusters.map { $0.cluster.name })

            for cluster in clusters {
                let clusterKey = cluster.cluster.name
                var marker: NMFMarker
                if let existingMarker = clusterMarkerDictionary[clusterKey] {
                    marker = existingMarker
                    if marker.position.lat != cluster.cluster.coordinate.lat ||
                        marker.position.lng != cluster.cluster.coordinate.lng {
                        marker.position = NMGLatLng(lat: cluster.cluster.coordinate.lat, lng: cluster.cluster.coordinate.lng)
                    }
                } else {
                    marker = NMFMarker()
                    clusterMarkerDictionary[clusterKey] = marker
                }

                marker.position = NMGLatLng(lat: cluster.cluster.coordinate.lat, lng: cluster.cluster.coordinate.lng)
                marker.userInfo = ["clusterData": cluster]

                if let clusterImage = createClusterMarkerImage(regionName: cluster.cluster.name, count: cluster.storeCount) {
                    marker.iconImage = NMFOverlayImage(image: clusterImage)
                } else {
                    marker.iconImage = NMFOverlayImage(name: "cluster_marker")
                }

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

    private func addMarkers(for stores: [MapPopUpStore]) {
        markerDictionary.values.forEach { $0.mapView = nil }
        markerDictionary.removeAll()

        for store in stores {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
            marker.userInfo = ["storeData": store]

            updateMarkerStyle(marker: marker, selected: false, isCluster: false)

            marker.touchHandler = { [weak self] (_) -> Bool in
                guard let self = self else { return false }

                print("검색 결과 마커 터치됨! 스토어: \(store.name)")
                return self.handleSingleStoreTap(marker, store: store)
            }

            marker.mapView = mainView.mapView
            markerDictionary[store.id] = marker
        }
    }
        private func updateListView(with results: [MapPopUpStore]) {
        let storeItems = results.map { store in
            StoreItem(
                id: store.id,
                thumbnailURL: store.mainImageUrl ?? "",
                category: store.category,
                title: store.name,
                location: store.address,
                dateRange: "\(store.startDate) ~ \(store.endDate)",
                isBookmarked: false
            )
        }
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
                    "위치 서비스가 비활성화되었습니다. 설정에서 권한을 확인해주세요.",
                    category: .error
                )
                mainView.mapView.positionMode = .disabled
            @unknown default:
                break
            }
        }

        private func updateTooltipPosition() {
            guard let marker = currentMarker, let tooltip = currentTooltipView else { return }
            let markerPoint = mainView.mapView.projection.point(from: marker.position)
            var markerCenter = markerPoint

            markerCenter.y = markerPoint.y - 20

            let offsetX: CGFloat = -10
            let offsetY: CGFloat = -10

            tooltip.frame.origin = CGPoint(
                x: markerCenter.x + offsetX,
                y: markerCenter.y - tooltip.frame.height - offsetY
            )
        }

        private func resetSelectedMarker() {
            if let currentMarker = currentMarker {
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
            marker.touchHandler = { [weak self] (_) -> Bool in
                guard let self = self else { return false }

                print("클러스터 내 마커 터치됨! 스토어: \(store.name)")
                return self.handleSingleStoreTap(marker, store: store)
            }

            marker.mapView = mainView.mapView
            individualMarkerDictionary[store.id] = marker
        }
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
            for marker in clusterMarkerDictionary.values {
                if let clusterData = marker.userInfo["clusterData"] as? ClusterMarkerData,
                   clusterData.cluster.stores.contains(where: { $0.id == store.id }) {
                    return marker
                }
            }
            return nil
        }

        private func fetchStoreDetails(for stores: [MapPopUpStore]) {
            guard !stores.isEmpty else { return }
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
            self.storeListViewController.reactor?.action.onNext(.setStores(initialStoreItems))
            stores.forEach { store in
                self.popUpAPIUseCase.getPopUpDetail(
                    commentType: "NORMAL",
                    popUpStoredId: store.id,
                    isViewCount: true
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

            // 최초 진입시에만 자동 포커싱/캐러셀 동작
            reactor.state
                .map { $0.viewportStores }
                .distinctUntilChanged()
                .filter { !$0.isEmpty }
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] stores in
                    guard let self = self else { return }
                    // 최초 진입시에만 자동 포커싱/캐러셀 동작
                    if self.isFirstViewportEntry {
                        self.isFirstViewportEntry = false

                        if let location = self.locationManager.location {
                            self.findAndShowNearestStore(from: location)
                        } else if let firstStore = stores.first,
                                  let marker = self.findMarkerForStore(for: firstStore) {
                            _ = self.handleSingleStoreTap(marker, store: firstStore)
                        }
                    }
                    self.currentStores = stores
                    self.updateMapWithClustering()
                })
                .disposed(by: disposeBag)

            // 지도 이동시 자동 캐러셀/포커싱 등 UI 업데이트 제거
            reactor.state
                .map { $0.viewportStores }
                .distinctUntilChanged()
                .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.updateMapWithClustering()
                })
                .disposed(by: disposeBag)
        }

    private func findAndShowNearestStore(from location: CLLocation) {
            guard !currentStores.isEmpty else {
                Logger.log("현재위치 표기할 스토어가 없습니다", category: .debug)
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
            } else if let store = nearestStore {
                let marker = NMFMarker()
                marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                marker.userInfo = ["storeData": store]
                marker.anchor = CGPoint(x: 0.5, y: 1.0)

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

            if let previousMarker = currentMarker {
                updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
            }
            updateMarkerStyle(marker: marker, selected: true, isCluster: false)
            currentMarker = marker
            if currentCarouselStores.isEmpty || !currentCarouselStores.contains(where: { $0.id == store.id }) {
                let bounds = getVisibleBounds()

                let visibleStores = currentStores.filter { store in
                    let storePosition = NMGLatLng(lat: store.latitude, lng: store.longitude)
                    return NMGLatLngBounds(southWest: bounds.southWest, northEast: bounds.northEast).contains(storePosition)
                }

                if !visibleStores.isEmpty {
                    currentCarouselStores = visibleStores
                    carouselView.updateCards(visibleStores)

                    if let index = visibleStores.firstIndex(where: { $0.id == store.id }) {
                        carouselView.scrollToCard(index: index)
                    }
                } else {
                    currentCarouselStores = [store]
                    carouselView.updateCards([store])
                }
            } else {
                if let index = currentCarouselStores.firstIndex(where: { $0.id == store.id }) {
                    carouselView.scrollToCard(index: index)
                }
            }

            carouselView.isHidden = false
            mainView.setStoreCardHidden(false, animated: true)

            if let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore], storeArray.count > 1 {
                configureTooltip(for: marker, stores: storeArray)
                if let index = storeArray.firstIndex(where: { $0.id == store.id }) {
                    (currentTooltipView as? MarkerTooltipView)?.selectStore(at: index)
                }
            } else {
                currentTooltipView?.removeFromSuperview()
                currentTooltipView = nil
            }

            isMovingToMarker = false
            return true
        }

    func handleRegionalClusterTap(_ marker: NMFMarker, clusterData: ClusterMarkerData) -> Bool {

        let currentZoom = mainView.mapView.zoomLevel
        let currentLevel = MapZoomLevel.getLevel(from: Float(currentZoom))
        switch currentLevel {
        case .city:
            let districtZoomLevel: Double = 10.0
            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: districtZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
            mainView.mapView.moveCamera(cameraUpdate)

        case .district:
            let detailedZoomLevel: Double = 12.0
            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: detailedZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
            mainView.mapView.moveCamera(cameraUpdate)
            default:
            print("기타")
        }
        updateMarkersForCluster(stores: clusterData.cluster.stores)
        carouselView.updateCards(clusterData.cluster.stores)
        carouselView.isHidden = false
        self.currentCarouselStores = clusterData.cluster.stores
        return true
    }

        func handleMicroClusterTap(_ marker: NMFMarker, storeArray: [MapPopUpStore]) -> Bool {
            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil
            currentTooltipStores = []
            currentTooltipCoordinate = nil

            if let previousMarker = currentMarker {
                updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
            }

            updateMarkerStyle(marker: marker, selected: true, isCluster: false, count: storeArray.count)
            currentMarker = marker

            // 3. 캐러셀/툴팁 갱신
            currentCarouselStores = storeArray
            carouselView.updateCards(storeArray)
            carouselView.isHidden = false
            carouselView.scrollToCard(index: 0)
            mainView.setStoreCardHidden(false, animated: true)

            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
            mainView.mapView.moveCamera(cameraUpdate)

            // 4. 툴팁 갱신 및 위치 재계산
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                self.configureTooltip(for: marker, stores: storeArray)
                self.isMovingToMarker = false
            }

            return true
        }

        private func showNoMarkersToast() {
            Logger.log("현재 지도 영역에 표시할 마커가 없습니다", category: .debug)
        }
    }

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }

            currentMarker?.mapView = nil
            currentMarker = nil
            carouselView.isHidden = true
            currentCarouselStores = []

            let position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: position, zoomTo: Constants.defaultZoom)
            mainView.mapView.moveCamera(cameraUpdate) { [weak self] _ in
                guard let self = self else { return }
                self.findAndShowNearestStore(from: location)
            }

            locationManager.stopUpdatingLocation()
        }
    }

// MARK: - NMFMapViewTouchDelegate
extension MapViewController: NMFMapViewTouchDelegate {
        func mapView(_ mapView: NMFMapView, didTap marker: NMFMarker) -> Bool {
            if let clusterData = marker.userInfo["clusterData"] as? ClusterMarkerData {
                return handleRegionalClusterTap(marker, clusterData: clusterData)
            } else if let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore] {
                if storeArray.count > 1 {
                    return handleMicroClusterTap(marker, storeArray: storeArray)
                } else if let singleStore = storeArray.first {
                    return handleSingleStoreTap(marker, store: singleStore)
                }
            } else if let singleStore = marker.userInfo["storeData"] as? MapPopUpStore {
                return handleSingleStoreTap(marker, store: singleStore)
            }
            return false
        }

        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            guard !isMovingToMarker else { return }

            // 선택된 마커 초기화
            if let currentMarker = currentMarker {
                updateMarkerStyle(marker: currentMarker, selected: false, isCluster: false)
                self.currentMarker = nil
            }
            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil
            currentTooltipStores = []
            currentTooltipCoordinate = nil
            carouselView.isHidden = true
            carouselView.updateCards([])
            self.currentCarouselStores = []
            mainView.setStoreCardHidden(true, animated: true)
            updateMapWithClustering()
        }
    }

// MARK: - NMFMapViewCameraDelegate
extension MapViewController: NMFMapViewCameraDelegate {
        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            if reason == NMFMapChangedByGesture && !isMovingToMarker {
                resetSelectedMarker()
            }
        }
        func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
            if !isMovingToMarker {
                currentTooltipView?.removeFromSuperview()
                currentTooltipView = nil
                currentTooltipStores = []
                updateMapWithClustering()
                carouselView.isHidden = true
                carouselView.updateCards([])
                currentCarouselStores = []
            }
        }
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
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
            idleSubject.onNext(())
            cameraIdle.onNext(())
        }
    }
// MARK: - UIGestureRecognizerDelegate
extension MapViewController: UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            let touchPoint = touch.location(in: view)
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
