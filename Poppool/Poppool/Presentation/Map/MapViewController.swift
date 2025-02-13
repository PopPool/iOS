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
    
    
    fileprivate struct CoordinateKey: Hashable {
        let lat: Int
        let lng: Int
        
        init(latitude: Double, longitude: Double) {
            self.lat = Int(latitude * 1_000_00)
            self.lng = Int(longitude * 1_000_00)
        }
    }
    
    // (신규) 툴팁(팝업) 뷰를 담아둘 변수
    var currentTooltipView: UIView?
    var currentTooltipStores: [MapPopUpStore] = []
    var currentTooltipCoordinate: CLLocationCoordinate2D?
    
    // MARK: - Properties
    private var isMovingToMarker = false
    var currentCarouselStores: [MapPopUpStore] = []
    private var markerDictionary: [Int64: GMSMarker] = [:]
    private var individualMarkerDictionary: [Int64: GMSMarker] = [:]
    private var clusterMarkerDictionary: [String: GMSMarker] = [:]
    private let popUpAPIUseCase = PopUpAPIUseCaseImpl(
        repository: PopUpAPIRepositoryImpl(provider: ProviderImpl()))
    private let clusteringManager = ClusteringManager()
    var currentStores: [MapPopUpStore] = []
    var disposeBag = DisposeBag()
    let mainView = MapView()
    let carouselView = MapPopupCarouselView()
    private let locationManager = CLLocationManager()
    var currentMarker: GMSMarker?
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        checkLocationAuthorization()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mainView.mapView.isMyLocationEnabled = true
        
        carouselView.rx.observe(Bool.self, "hidden")
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isHidden in
                guard let self = self, let isHidden = isHidden else { return }
                self.mainView.setStoreCardHidden(isHidden, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.mapView.rx.idleAtPosition
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if let _ = self.currentTooltipView, let _ = self.currentMarker {
                    self.updateTooltipPosition()
                }
                self.isMovingToMarker = false
            })
            .disposed(by: disposeBag)
        
        // 초기 데이터 로드
        if let reactor = self.reactor {
            reactor.action.onNext(.fetchCategories)
            
            // 한국 전체 영역에 대한 경계값 설정
            // 대한민국의 대략적인 경계 좌표
            let koreaRegion = (
                northEast: CLLocationCoordinate2D(latitude: 38.0, longitude: 132.0),  // 한국 북동쪽 끝
                southWest: CLLocationCoordinate2D(latitude: 33.0, longitude: 124.0)   // 한국 남서쪽 끝
            )
            
            reactor.action.onNext(.viewportChanged(
                northEastLat: koreaRegion.northEast.latitude,
                northEastLon: koreaRegion.northEast.longitude,
                southWestLat: koreaRegion.southWest.latitude,
                southWestLon: koreaRegion.southWest.longitude
            ))
        }
        
        
        //        mainView.mapView.settings.myLocationButton = true
        
        //        carouselView.onCardScrolled = { [weak self] pageIndex in
        //            guard let self = self,
        //                  pageIndex >= 0,
        //                  pageIndex < self.currentCarouselStores.count else { return }
        //
        //            let store = self.currentCarouselStores[pageIndex]
        //
        //            // 1. 현재 선택된 스토어의 마커 찾기
        //            if let existingMarker = self.findMarkerForStore(for: store) {
        //                // 1-1. 이전 마커 선택 해제
        //                if let previousMarker = self.currentMarker, previousMarker != existingMarker {
        //                    let markerView = MapMarker()
        //                    let storeCount = (previousMarker.userData as? [MapPopUpStore])?.count ?? 1
        //                    markerView.injection(with: .init(
        //                        isSelected: false,
        //                        isCluster: false,
        //                        count: storeCount
        //                    ))
        //                    previousMarker.iconView = markerView
        //                }
        //
        //                // 1-2. 새 마커 선택 상태로 변경
        //                let markerView = MapMarker()
        //                let storeCount = (existingMarker.userData as? [MapPopUpStore])?.count ?? 1
        //                markerView.injection(with: .init(
        //                    isSelected: true,
        //                    isCluster: false,
        //                    count: storeCount
        //                ))
        //                existingMarker.iconView = markerView
        //                self.currentMarker = existingMarker
        //
        //                // 2. 툴팁 업데이트
        //                if let storeArray = existingMarker.userData as? [MapPopUpStore] {
        //                    // 마커에 연결된 스토어가 2개 이상인 경우에만 툴팁 표시
        //                    if storeArray.count > 1 {
        //                        // 기존 툴팁이 없거나 다른 마커의 툴팁인 경우 새로 생성
        //                        if self.currentTooltipView == nil || self.currentTooltipCoordinate != existingMarker.position {
        //                            // 기존 툴팁 제거
        //                            self.currentTooltipView?.removeFromSuperview()
        //
        //                            let tooltipView = MarkerTooltipView()
        //                            tooltipView.configure(with: storeArray)
        //                            tooltipView.onStoreSelected = { [weak self] index in
        //                                guard let self = self,
        //                                      index < storeArray.count else { return }
        //                                let selectedStore = storeArray[index]
        //                                if let carouselIndex = self.currentCarouselStores.firstIndex(where: { $0.id == selectedStore.id }) {
        //                                    self.carouselView.scrollToCard(index: carouselIndex)
        //                                }
        //                            }
        //
        //                            // 마커 위치 기준으로 툴팁 위치 설정
        //                            let markerPoint = self.mainView.mapView.projection.point(for: existingMarker.position)
        //                            let markerHeight = (existingMarker.iconView as? MapMarker)?.imageView.frame.height ?? 32
        //                            tooltipView.frame = CGRect(
        //                                x: markerPoint.x - 10,
        //                                y: markerPoint.y - markerHeight - tooltipView.frame.height - 10,
        //                                width: tooltipView.frame.width,
        //                                height: tooltipView.frame.height
        //                            )
        //
        //                            self.mainView.addSubview(tooltipView)
        //                            self.currentTooltipView = tooltipView
        //                            self.currentTooltipStores = storeArray
        //                            self.currentTooltipCoordinate = existingMarker.position
        //                        }
        //
        //                        // 툴팁의 선택된 행 업데이트
        //                        if let tooltipIndex = storeArray.firstIndex(where: { $0.id == store.id }) {
        //                            (self.currentTooltipView as? MarkerTooltipView)?.selectStore(at: tooltipIndex)
        //                        }
        //                    } else {
        //                        // 단일 마커의 경우 툴팁 제거
        //                        self.currentTooltipView?.removeFromSuperview()
        //                        self.currentTooltipView = nil
        //                        self.currentTooltipStores = []
        //                        self.currentTooltipCoordinate = nil
        //                    }
        //                }
        //
        //                // 3. 지도 중심 이동 및 애니메이션
        //                let camera = GMSCameraUpdate.setTarget(existingMarker.position)
        //                self.mainView.mapView.animate(with: camera)
        //
        //                // 4. 리액터에 선택된 스토어 상태 업데이트
        //                self.reactor?.action.onNext(.didSelectItem(store))
        //
        //                // 5. 로깅
        //                Logger.log(
        //                    message: """
        //                    캐러셀 카드 변경:
        //                    - 페이지 인덱스: \(pageIndex)
        //                    - 선택된 스토어: \(store.name)
        //                    - 마커 위치: (\(existingMarker.position.latitude), \(existingMarker.position.longitude))
        //                    - 툴팁 표시 여부: \(self.currentTooltipView != nil)
        //                    """,
        //                    category: .debug
        //                )
        //            }
        //        }
        
        // 캐러셀 스크롤 핸들러
        carouselView.onCardScrolled = { [weak self] pageIndex in
            guard let self = self,
                  pageIndex >= 0,
                  pageIndex < self.currentCarouselStores.count else { return }
            
            let store = self.currentCarouselStores[pageIndex]
            
            Logger.log(message: """
                캐러셀 스크롤:
                - 현재 페이지: \(pageIndex)
                - 선택된 스토어: \(store.name)
                """, category: .debug)
            
            if let existingMarker = self.currentMarker,
               let markerStores = existingMarker.userData as? [MapPopUpStore] {
                
                // 1. 마커 뷰 업데이트
                if let currentMarkerView = existingMarker.iconView as? MapMarker {
                    currentMarkerView.injection(with: .init(
                        isSelected: true,
                        isCluster: false,
                        count: markerStores.count
                    ))
                }
                
                // 2. 툴팁 업데이트
                if markerStores.count > 1 {
                    if self.currentTooltipView == nil {
                        self.configureTooltip(for: existingMarker, stores: markerStores)
                    }
                    
                    // 현재 캐러셀의 스토어에 해당하는 툴팁 인덱스 찾기
                    if let tooltipIndex = markerStores.firstIndex(where: { $0.id == store.id }) {
                        Logger.log(message: """
                            툴팁 업데이트:
                            - 선택된 스토어: \(store.name)
                            - 툴팁 인덱스: \(tooltipIndex)
                            """, category: .debug)
                        (self.currentTooltipView as? MarkerTooltipView)?.selectStore(at: tooltipIndex)
                    }
                }
            }
        }
        
        
        if let reactor = self.reactor {
            bindViewport(reactor: reactor)
            reactor.action.onNext(.fetchCategories)
            
        }
        
    }
    private func configureTooltip(for marker: GMSMarker, stores: [MapPopUpStore]) {
        Logger.log(message: """
           툴팁 설정:
           - 현재 캐러셀 스토어: \(currentCarouselStores.map { $0.name })
           - 마커 스토어: \(stores.map { $0.name })
           """, category: .debug)
        
        self.currentTooltipView?.removeFromSuperview()
        
        let tooltipView = MarkerTooltipView()
        tooltipView.configure(with: stores)
        
        let markerPoint = self.mainView.mapView.projection.point(for: marker.position)
        let markerHeight = (marker.iconView as? MapMarker)?.imageView.frame.height ?? 32
        tooltipView.frame = CGRect(
            x: markerPoint.x - tooltipView.frame.width/2,
            y: markerPoint.y - markerHeight - tooltipView.frame.height - 20,
            width: tooltipView.frame.width,
            height: tooltipView.frame.height
        )
        
        tooltipView.onStoreSelected = { [weak self] index in
            guard let self = self,
                  index < stores.count else { return }
            
            // handleMicroClusterTap과 동일한 방식으로 처리
            self.currentCarouselStores = stores
            self.carouselView.updateCards(stores)
            self.carouselView.scrollToCard(index: index)
            
            // 마커 상태 유지
            if let markerView = marker.iconView as? MapMarker {
                markerView.injection(with: .init(
                    isSelected: true,
                    isCluster: false,
                    count: stores.count
                ))
            }
            
            // 툴팁 선택 상태 업데이트
            tooltipView.selectStore(at: index)
            
            Logger.log(message: """
               툴팁 선택:
               - 선택된 스토어: \(stores[index].name)
               - 툴팁 인덱스: \(index)
               """, category: .debug)
        }
        
        // 툴팁 표시 및 상태 저장
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
        
        //        if let reactor = self.reactor {
        //                bind(reactor: reactor)
        //            }
        
        // 제스처 설정
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        storeListViewController.mainView.grabberHandle.addGestureRecognizer(panGesture)
        storeListViewController.mainView.addGestureRecognizer(panGesture)
        setupPanAndSwipeGestures()
        
        
        //        setupMarker()
    }
    
    private let defaultZoomLevel: Float = 15.0
    
    
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
        //        mainView.searchInput.onSearch = { [weak self] query in
        //            self?.reactor?.action.onNext(.searchTapped(query))
        //        }
        //
        //        reactor.state.map { $0.isLoading }
        //            .distinctUntilChanged()
        //            .observe(on: MainScheduler.instance)
        //            .bind { [weak self] isLoading in
        //                self?.mainView.searchInput.searchTextField.isEnabled = !isLoading
        ////                self?.mainView.searchInput.setLoading(isLoading)
        //            }
        //            .disposed(by: disposeBag)
        
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
                
                // 기존 데이터 초기화
                self.mainView.mapView.clear()
                self.storeListViewController.reactor?.action.onNext(.setStores([]))
                self.carouselView.updateCards([])
                self.carouselView.isHidden = true
                
                if results.isEmpty {
                    self.mainView.setStoreCardHidden(true, animated: true)
                    return
                } else {
                    self.mainView.setStoreCardHidden(false, animated: true)
                }
                
                // 전체 마커를 한 번에 추가
                self.addMarkers(for: results)
                
                //                 (원래는 캐러셀 업데이트와 리스트 업데이트를 진행하지만, 테스트 시에는 주석 처리)
                let storeItems = results.map { $0.toStoreItem() }
                self.storeListViewController.reactor?.action.onNext(.setStores(storeItems))
                self.carouselView.updateCards(results)
                self.carouselView.isHidden = false
                
                // 첫 번째 검색 결과로 지도 이동
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
        
        
        
        //        reactor.state.map { $0.searchResults.isEmpty }
        //            .distinctUntilChanged()
        //            .skip(1)  // 초기값 스킵
        //            .observe(on: MainScheduler.instance)
        //            .bind { [weak self] isEmpty in
        //                guard let self = self else { return }
        //                if isEmpty {
        //                    self.showAlert(
        //                        title: "검색 결과 없음",
        //                        message: "검색 결과가 없습니다. 다른 키워드로 검색해보세요."
        //                    )
        //                }
        //            }
        //            .disposed(by: disposeBag)
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

        marker.groundAnchor = CGPoint(x: 0.5, y: 0.0)

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
                let offset = max(self.view.frame.height * 0.3, self.filterContainerBottomY)
                self.listViewTopConstraint?.update(offset: offset)
                self.storeListViewController.mainView.layer.cornerRadius = 20
                self.storeListViewController.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.mainView.mapView.alpha = 1
                self.mainView.mapView.isHidden = false
                self.mainView.searchInput.setBackgroundColor(.white)
                
                
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
    
    
    // MARK: - Clustering
    private func updateMapWithClustering() {
        let currentZoom = mainView.mapView.camera.zoom
        let level = MapZoomLevel.getLevel(from: currentZoom)
        
        switch level {
        case .detailed:
            clusterMarkerDictionary.values.forEach { $0.map = nil }
            
            let groupedDict = groupStoresByExactLocation(currentStores)
            for (_, storeGroup) in groupedDict {
                if storeGroup.count == 1, let store = storeGroup.first {
                    // (C-1) 단일 스토어 -> 일반 마커
                    if let marker = individualMarkerDictionary[store.id] {
                        // 이미 존재하면 위치만 업데이트
                        if marker.position.latitude != store.latitude ||
                            marker.position.longitude != store.longitude {
                            marker.position = store.coordinate
                        }
                        // 선택 상태 유지를 위한 체크
                        let isSelected = (marker == currentMarker)
                        if let markerView = marker.iconView as? MapMarker {
                            markerView.injection(with: .init(
                                isSelected: isSelected,
                                isCluster: false
                            ))
                        }
                        marker.map = mainView.mapView
                    } else {
                        // 새 마커
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
                        
                        individualMarkerDictionary[store.id] = marker
                    }
                    
                } else {
                    guard let firstStore = storeGroup.first else { continue }
                    
                    let markerKey = firstStore.id
                    if let existingMarker = individualMarkerDictionary[markerKey] {
                        existingMarker.position = firstStore.coordinate
                        existingMarker.map = mainView.mapView
                        existingMarker.userData = storeGroup
                        
                        // 선택 상태 유지를 위한 체크
                        let isSelected = (existingMarker == currentMarker)
                        if let markerView = existingMarker.iconView as? MapMarker {
                            markerView.injection(with: .init(
                                isSelected: isSelected,
                                isCluster: false,
                                regionName: "",
                                count: storeGroup.count
                            ))
                        }
                    } else {
                        // 새 마커
                        let marker = GMSMarker(position: firstStore.coordinate)
                        marker.userData = storeGroup
                        
                        let markerView = MapMarker()
                        markerView.injection(with: .init(
                            isSelected: false,
                            isCluster: false,
                            regionName: "",
                            count: storeGroup.count
                        ))
                        marker.iconView = markerView
                        marker.map = mainView.mapView
                        
                        individualMarkerDictionary[markerKey] = marker
                    }
                }
            }
            
            // (D) 기존에 더 이상 필요 없어졌는데 남아있는 개별 마커 제거
            let newIDs = groupedDict.values.flatMap { $0.map { $0.id } }
            let newIDSet = Set(newIDs)
            for (id, marker) in individualMarkerDictionary {
                // id가 새 목록에 없으면 지도에서 제거
                if !newIDSet.contains(id) {
                    marker.map = nil
                    individualMarkerDictionary.removeValue(forKey: id)
                }
            }
            
        case .district, .city, .country:  // 클러스터 마커
            // 개별 마커는 숨기기만 하고 제거하지 않음
            individualMarkerDictionary.values.forEach { $0.map = nil }
            
            let clusters = clusteringManager.clusterStores(currentStores, at: currentZoom)
            
            // 클러스터 마커 업데이트 또는 추가
            for cluster in clusters {
                let clusterKey = cluster.cluster.name
                
                if let existingMarker = clusterMarkerDictionary[clusterKey] {
                    // 기존 마커 표시 및 업데이트
                    existingMarker.map = mainView.mapView
                    existingMarker.position = cluster.cluster.coordinate
                    
                    // 카운트가 변경된 경우에만 마커 뷰 업데이트
                    if let existingCluster = existingMarker.userData as? ClusterMarkerData,
                       existingCluster.storeCount != cluster.storeCount {
                        let markerView = MapMarker()
                        markerView.injection(with: .init(
                            isSelected: false,
                            isCluster: true,
                            regionName: cluster.cluster.name,
                            count: cluster.storeCount
                        ))
                        existingMarker.iconView = markerView
                    }
                    existingMarker.userData = cluster
                } else {
                    // 새 클러스터 마커 생성
                    let marker = GMSMarker(position: cluster.cluster.coordinate)
                    marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                    
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
                    
                    clusterMarkerDictionary[clusterKey] = marker
                }
            }
            
            // 현재 표시되지 않는 클러스터 마커는 숨기기
            let activeClusterKeys = Set(clusters.map { $0.cluster.name })
            clusterMarkerDictionary.forEach { (key, marker) in
                if !activeClusterKeys.contains(key) {
                    marker.map = nil
                }
            }
        }
    }
    private func clearAllMarkers() {
        individualMarkerDictionary.values.forEach { $0.map = nil }
        individualMarkerDictionary.removeAll()
        
        clusterMarkerDictionary.values.forEach { $0.map = nil }
        clusterMarkerDictionary.removeAll()
        
        markerDictionary.values.forEach { $0.map = nil }
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
                if marker.position.latitude != store.latitude || marker.position.longitude != store.longitude {
                    marker.position = store.coordinate
                }
            } else {
                // 새 마커 생성 및 추가
                let marker = GMSMarker(position: store.coordinate)
                marker.userData = store
                
                let markerView = MapMarker()
                markerView.injection(with: store.toMarkerInput())
                marker.iconView = markerView
                marker.map = mainView.mapView
                
                individualMarkerDictionary[store.id] = marker
            }
        }
        for (id, marker) in individualMarkerDictionary {
            if !newMarkerIDs.contains(id) {
                marker.map = nil
                individualMarkerDictionary.removeValue(forKey: id)
            }
        }
    }
    private func updateClusterMarkers(_ clusters: [ClusterMarkerData]) {
        for clusterData in clusters {
            let clusterKey = clusterData.cluster.name
            let fixedCoordinate = clusterData.cluster.coordinate
            
            if let marker = clusterMarkerDictionary[clusterKey] {
                if marker.position.latitude != fixedCoordinate.latitude ||
                    marker.position.longitude != fixedCoordinate.longitude {
                    marker.position = fixedCoordinate
                }
            } else {
                let marker = GMSMarker()
                marker.position = fixedCoordinate
                marker.userData = clusterData
                
                let markerView = MapMarker()
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: true,
                    regionName: clusterData.cluster.name,
                    count: clusterData.storeCount
                ))
                marker.iconView = markerView
                marker.map = mainView.mapView
                
                clusterMarkerDictionary[clusterKey] = marker
            }
        }
    }
    
    
    
    
    func presentFilterBottomSheet(for filterType: FilterType) {
        let sheetReactor = FilterBottomSheetReactor()
        let viewController = FilterBottomSheetViewController(reactor: sheetReactor)
        
        let initialIndex = (filterType == .location) ? 0 : 1
        viewController.containerView.segmentedControl.selectedSegmentIndex = initialIndex
        sheetReactor.action.onNext(.segmentChanged(initialIndex))
        
        viewController.onSave = { [weak self] filterData in
            
        }
        
        viewController.onSave = { [weak self] filterData in
            guard let self = self else { return }
            self.reactor?.action.onNext(.updateBothFilters(
                locations: filterData.locations,
                categories: filterData.categories
            ))
            self.reactor?.action.onNext(.filterTapped(nil))
            
            let bounds = self.mainView.mapView.projection.visibleRegion()
            self.reactor?.action.onNext(.viewportChanged(
                northEastLat: bounds.farRight.latitude,
                northEastLon: bounds.farRight.longitude,
                southWestLat: bounds.nearLeft.latitude,
                southWestLon: bounds.nearLeft.longitude
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
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showLocationPermissionBottomSheet()
        @unknown default:
            break
        }
    }
    
    private func showLocationPermissionBottomSheet() {
        let bottomSheet = LocationPermissionBottomSheet()
        bottomSheet.modalPresentationStyle = .overFullScreen
        present(bottomSheet, animated: true)
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
        
        // (1) 구/시 단위 클러스터
        if let clusterData = marker.userData as? ClusterMarkerData {
            return handleRegionalClusterTap(marker, clusterData: clusterData)
        }
        // (2) 동일 좌표 마이크로 클러스터
        else if let storeArray = marker.userData as? [MapPopUpStore] {
            if storeArray.count > 1 {
                return handleMicroClusterTap(marker, storeArray: storeArray)
            } else if let singleStore = storeArray.first {
                return handleSingleStoreTap(marker, store: singleStore)
            }
        }
        // (3) 단일 스토어
        else if let singleStore = marker.userData as? MapPopUpStore {
            return handleSingleStoreTap(marker, store: singleStore)
        }
        
        // 그 외
        return false
    }
    
    
    
    /// 지도 이동할 때 클러스터 업데이트
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        if !isMovingToMarker {
//            currentTooltipView?.removeFromSuperview()
//            currentTooltipView = nil
//            currentTooltipStores = []
//
//            updateMapWithClustering()
//
//            // 뷰포트 변경 처리
//            let bounds = mapView.projection.visibleRegion()
//            reactor?.action.onNext(.viewportChanged(
//                northEastLat: bounds.farRight.latitude,
//                northEastLon: bounds.farRight.longitude,
//                southWestLat: bounds.nearLeft.latitude,
//                southWestLon: bounds.nearLeft.longitude
//            ))
//
//            // 현재 마커가 있다면 툴팁 위치도 업데이트
//            if currentMarker != nil {
//                updateTooltipPosition()
//            }
//            // 캐러셀 초기화
//            carouselView.isHidden = true
//            carouselView.updateCards([])
//            currentCarouselStores = []
//        }
//    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // 마커 탭으로 인한 이동 중일 때는
        // 툴팁 위치 업데이트만 하고 다른 상태 변경은 하지 않음
        if isMovingToMarker {
            if let _ = currentMarker {
                updateTooltipPosition()
            }
            return
        }

        // 일반 드래그 시에만 실행
        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil
        currentTooltipStores = []

        // 이전 선택된 마커가 있었다면 상태 해제
        if let currentMarker = currentMarker {
            let markerView = MapMarker()
            markerView.injection(with: .init(
                isSelected: false,
                isCluster: false,
                count: (currentMarker.userData as? [MapPopUpStore])?.count ?? 1
            ))
            currentMarker.iconView = markerView
        }

        // 마커 참조 제거
        currentMarker = nil

        // 캐러셀 초기화
        carouselView.isHidden = true
        carouselView.updateCards([])
        currentCarouselStores = []
        mainView.setStoreCardHidden(true, animated: true)
    }


    // 지도 움직임이 시작될 때의 핸들러도 수정
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        // 제스처(드래그)로 인한 이동이고, 마커 탭으로 인한 이동이 아닐 때만
        if gesture && !isMovingToMarker {
            resetSelectedMarker()
        }
    }

    /// 지도 빈 공간 탭 → 기존 마커/캐러셀 해제
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // 툴팁 제거
        guard !isMovingToMarker else { return }

        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil

        if let currentMarker = currentMarker {
            let markerView = MapMarker()

            // 마커가 클러스터인 경우를 위한 처리
            if let storeArray = currentMarker.userData as? [MapPopUpStore] {
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: false,
                    count: storeArray.count  // 기존 카운트 유지
                ))
            } else {
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: false
                ))
            }
            currentMarker.iconView = markerView
        }

        // 현재 마커 참조 제거
        currentMarker = nil

        // 캐러셀 초기화
        carouselView.isHidden = true
        carouselView.updateCards([])
        self.currentCarouselStores = []
        mainView.setStoreCardHidden(true, animated: true)

    }

    // MARK: - Helper for single marker tap
    private func handleSingleStoreTap(_ marker: GMSMarker, store: MapPopUpStore) -> Bool {
        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil

        if currentMarker == marker {
            return false
        }
        marker.appearAnimation = .none


        // 먼저 마커 상태 변경
        if let previousMarker = currentMarker {
            let markerView = MapMarker()
            markerView.injection(with: .init(
                isSelected: false,
                isCluster: false,
                count: (previousMarker.userData as? [MapPopUpStore])?.count ?? 1
            ))
            previousMarker.iconView = markerView
        }

        let markerView = MapMarker()
        markerView.injection(with: .init(
            isSelected: true,
            isCluster: false,
            count: 1
        ))
        marker.iconView = markerView
        currentMarker = marker

        // 마커 상태 변경 후에 이동 플래그 설정
        isMovingToMarker = true


        // 캐러셀 업데이트 (해당 마커에 연관된 스토어만 표시)
        carouselView.updateCards([store])
        carouselView.isHidden = false
        currentCarouselStores = [store]
        carouselView.scrollToCard(index: 0)
        mainView.setStoreCardHidden(false, animated: true)


//        isMovingToMarker = true
        mainView.mapView.animate(toLocation: marker.position)
        return true
    }


    private func handleRegionalClusterTap(_ marker: GMSMarker, clusterData: ClusterMarkerData) -> Bool {
        let currentZoom = mainView.mapView.camera.zoom
        let currentLevel = MapZoomLevel.getLevel(from: currentZoom)

        switch currentLevel {
        case .city:  // 시 단위 클러스터
            let districtZoomLevel: Float = 10.0
            let camera = GMSCameraPosition(target: marker.position, zoom: districtZoomLevel)
            mainView.mapView.animate(to: camera)

        case .district:  // 구 단위 클러스터
            let detailedZoomLevel: Float = 12.0
            let camera = GMSCameraPosition(target: marker.position, zoom: detailedZoomLevel)
            mainView.mapView.animate(to: camera)

        default:
            break
        }

        // 캐러셀 업데이트는 공통
        carouselView.updateCards(clusterData.cluster.stores)
        carouselView.isHidden = false
        self.currentCarouselStores = clusterData.cluster.stores

        return true
    }


    private func handleMicroClusterTap(_ marker: GMSMarker, storeArray: [MapPopUpStore]) -> Bool {
        // 이미 선택된 마커를 다시 탭하면 해제
        if currentMarker == marker {
//            resetSelectedMarker()
            return false
        }

        // 기존 상태 초기화
        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil

        // 이전 마커 선택 해제
        if let previousMarker = currentMarker {
            let markerView = MapMarker()
            markerView.injection(with: .init(
                isSelected: false,
                isCluster: false,
                count: (previousMarker.userData as? [MapPopUpStore])?.count ?? 1
            ))
            previousMarker.iconView = markerView
        }

        // 새 마커 선택
        let markerView = MapMarker()
        markerView.injection(with: .init(
            isSelected: true,
            isCluster: false,
            count: storeArray.count
        ))
        marker.iconView = markerView
        currentMarker = marker

        // 캐러셀 업데이트
        currentCarouselStores = storeArray
        carouselView.updateCards(storeArray)
        carouselView.isHidden = false

        // 툴팁 설정
        let tooltipView = MarkerTooltipView()
        tooltipView.configure(with: storeArray)

        // 툴팁 탭 핸들러
        tooltipView.onStoreSelected = { [weak self] index in
            guard let self = self else { return }

            // 캐러셀 업데이트 - 동일한 스토어 배열 사용
            if index < storeArray.count {
                self.carouselView.scrollToCard(index: index)
            }
        }

        // 툴팁 위치 설정
        let markerPoint = mainView.mapView.projection.point(for: marker.position)
        let markerHeight = (marker.iconView as? MapMarker)?.imageView.frame.height ?? 32
        tooltipView.frame = CGRect(
            x: markerPoint.x - 10,
            y: markerPoint.y - markerHeight - tooltipView.frame.height - 14,
            width: tooltipView.frame.width,
            height: tooltipView.frame.height
        )

        mainView.addSubview(tooltipView)
         currentTooltipView = tooltipView
         currentTooltipStores = storeArray
         currentTooltipCoordinate = marker.position

         // 첫 번째 아이템으로 캐러셀 스크롤
         carouselView.scrollToCard(index: 0)

        mainView.setStoreCardHidden(false, animated: true)
         isMovingToMarker = true
         mainView.mapView.animate(toLocation: marker.position)
         return true
     }

    private func updateTooltipPosition() {
        guard let marker = currentMarker, let tooltip = currentTooltipView else { return }

        let markerPoint = mainView.mapView.projection.point(for: marker.position)
        var markerCenter = markerPoint
        if let iconView = marker.iconView {
            markerCenter.y = markerPoint.y - iconView.bounds.height / 1.5
        }

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
            let markerView = MapMarker()

            if let storeArray = currentMarker.userData as? [MapPopUpStore] {
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: false,
                    count: storeArray.count
                ))
            } else {
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: false
                ))
            }
            currentMarker.iconView = markerView
        }

        // 🛠 툴팁 제거
        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil
        currentTooltipStores = []
        currentTooltipCoordinate = nil

        // 🛠 캐러셀 숨기기
        carouselView.isHidden = true
        carouselView.updateCards([])
        currentCarouselStores = []

        // 🛠 현재 마커 참조 제거
        self.currentMarker = nil
    }


}


extension MapViewController {
    func bindViewport(reactor: MapReactor) {
        let cameraObservable = Observable.merge([
            mainView.mapView.rx.didChangePosition,  // 카메라 움직임 중
            mainView.mapView.rx.idleAtPosition     // 카메라 멈춤
        ])
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)  // 디바운스 추가
            .map { [unowned self] in
                self.mainView.mapView.camera
            }

        let distinctCameraObservable = cameraObservable.distinctUntilChanged { (cam1, cam2) -> Bool in
            let loc1 = CLLocation(latitude: cam1.target.latitude, longitude: cam1.target.longitude)
            let loc2 = CLLocation(latitude: cam2.target.latitude, longitude: cam2.target.longitude)
            let distance = loc1.distance(from: loc2)
            // 50m 미만이면 변화가 없다고 판단
            if distance < 40 { return true }

            // 줌 레벨 변화가 있다면 반드시 업데이트
//            let zoomDiff = abs(cam1.zoom - cam2.zoom)
//            if zoomDiff >= 0.2 { return false }

            return false
        }


//        let viewportActionObservable = distinctCameraObservable.map { [unowned self] _ -> MapReactor.Action? in
//            let visibleRegion = self.mainView.mapView.projection.visibleRegion()
//            // 네 모서리 좌표 배열
//            let corners = [
//                visibleRegion.nearLeft,
//                visibleRegion.nearRight,
//                visibleRegion.farLeft,
//                visibleRegion.farRight
//            ]
//            let lats = corners.map { $0.latitude }
//            let lons = corners.map { $0.longitude }
//            let northEast = CLLocationCoordinate2D(latitude: lats.max() ?? 0, longitude: lons.max() ?? 0)
//            let southWest = CLLocationCoordinate2D(latitude: lats.min() ?? 0, longitude: lons.min() ?? 0)
//
//            return .viewportChanged(
//                northEastLat: northEast.latitude,
//                northEastLon: northEast.longitude,
//                southWestLat: southWest.latitude,
//                southWestLon: southWest.longitude
//            )
//        }
//            .compactMap { $0 }
//
//        // 4. 계산된 뷰포트 경계를 Reactor의 액션으로 바인딩합니다.
//        viewportActionObservable
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)

        // 5. Reactor의 viewportStores가 변경되면 currentStores 업데이트 후 클러스터 갱신
        reactor.state
            .map { $0.viewportStores }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [unowned self] stores in
                self.currentStores = stores
                self.updateMapWithClustering()
            }
            .disposed(by: disposeBag)

        // 6. viewportStores로부터 StoreItem 배열을 생성하여 리스트 뷰 업데이트
        reactor.state
            .map { $0.viewportStores }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [unowned self] (stores: [MapPopUpStore]) -> Observable<[StoreItem]> in
                return Observable.from(stores)
                    .flatMap { store -> Observable<StoreItem> in
                        return self.popUpAPIUseCase.getPopUpDetail(
                            commentType: "NORMAL",
                            popUpStoredId: store.id
                        )
                        .map { detail in
                            StoreItem(
                                id: store.id,
                                thumbnailURL: store.mainImageUrl ?? "",
                                category: store.category,
                                title: store.name,
                                location: store.address,
                                dateRange: "\(store.startDate ?? "") ~ \(store.endDate ?? "")",
                                isBookmarked: detail.bookmarkYn
                            )
                        }
                        .catchAndReturn(StoreItem(
                            id: store.id,
                            thumbnailURL: store.mainImageUrl ?? "",
                            category: store.category,
                            title: store.name,
                            location: store.address,
                            dateRange: "\(store.startDate ?? "") ~ \(store.endDate ?? "")",
                            isBookmarked: false
                        ))
                    }
                    .toArray()
                    .asObservable()
            }
            .bind { [unowned self] storeItems in
                self.storeListViewController.reactor?.action.onNext(.setStores(storeItems))
            }
            .disposed(by: disposeBag)
    }




    private func findMarkerForStore(for store: MapPopUpStore) -> GMSMarker? {
        if let marker = individualMarkerDictionary[store.id] {
            return marker
        }

        // 2. 클러스터 마커에서 찾기
        for marker in clusterMarkerDictionary.values {
            if let stores = (marker.userData as? [MapPopUpStore]),
               stores.contains(where: { $0.id == store.id }) {
                return marker
            }
        }

        return nil
    }

private func handleMarkerTap(_ marker: GMSMarker) -> Bool {
        // 1) 클러스터인지
    isMovingToMarker = true

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
    func updateMarkers(with newStores: [MapPopUpStore]) {
        // 새로운 스토어 ID 집합 생성
        let newStoreIDs = Set(newStores.map { $0.id })

        // 1. 기존 마커 업데이트 또는 추가
        for store in newStores {
            if let marker = individualMarkerDictionary[store.id] {
                // 위치 변경 등 업데이트 (미세한 차이가 있을 때만)
                if abs(marker.position.latitude - store.latitude) > 0.0001 ||
                   abs(marker.position.longitude - store.longitude) > 0.0001 {
                    marker.position = store.coordinate
                }
                // 필요한 경우 마커 상태 업데이트 (예: 선택 상태)
            } else {
                // 새로운 스토어이면 마커 생성
                let marker = GMSMarker(position: store.coordinate)
                marker.userData = store

                let markerView = MapMarker()
                markerView.injection(with: store.toMarkerInput())
                marker.iconView = markerView
                marker.map = mainView.mapView

                individualMarkerDictionary[store.id] = marker
            }
        }

        // 2. 기존 마커 중 새로운 목록에 없는 것 제거
        for (id, marker) in individualMarkerDictionary {
            if !newStoreIDs.contains(id) {
                marker.map = nil
                individualMarkerDictionary.removeValue(forKey: id)
            }
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
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
