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
    private var storeDetailsCache: [Int64: StoreItem] = [:]
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
        mainView.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)


        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mainView.mapView.isMyLocationEnabled = true
        checkLocationAuthorization()
        if let reactor = self.reactor {
            reactor.action.onNext(.fetchCategories)

            // 한국 전체 영역에 대한 경계값 설정
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
//            reactor.state
//                .map { $0.viewportStores }
//                .distinctUntilChanged()
//                .filter { !$0.isEmpty }
//                .take(1)
//                .compactMap { [weak self] stores -> (stores: [MapPopUpStore], location: CLLocation)? in
//                    guard let self = self,
//                          let location = self.locationManager.location else { return nil }
//                    return (stores: stores, location: location)
//                }
//                .subscribe(onNext: { [weak self] result in
//                    self?.findAndShowNearestStore(from: result.location)
//                })
//                .disposed(by: disposeBag)


        }


        
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

        mainView.mapView.rx.idleAtPosition
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if let marker = self.currentMarker,
                   let storeArray = marker.userData as? [MapPopUpStore] {
                    // tooltip이 없으면 생성, 있으면 위치 업데이트
                    if self.currentTooltipView == nil {
                        self.configureTooltip(for: marker, stores: storeArray)
                    } else {
                        self.updateTooltipPosition()
                    }
                }
                self.isMovingToMarker = false
            })
            .disposed(by: disposeBag)




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
//                        Logger.log(message: """
//                            툴팁 업데이트:
//                            - 선택된 스토어: \(store.name)
//                            - 툴팁 인덱스: \(tooltipIndex)
//                            """, category: .debug)
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

        // 기존 툴팁 제거
        self.currentTooltipView?.removeFromSuperview()

        let tooltipView = MarkerTooltipView()
        tooltipView.configure(with: stores)

        // 선택된 상태로 표시 - 첫 번째 정보를 기본 선택 상태로 만듦
        tooltipView.selectStore(at: 0)

        // onStoreSelected 클로저 설정
        tooltipView.onStoreSelected = { [weak self] index in
            guard let self = self, index < stores.count else { return }
            self.currentCarouselStores = stores
            self.carouselView.updateCards(stores)
            self.carouselView.scrollToCard(index: index)

            // 선택된 상태로 업데이트
            if let markerView = marker.iconView as? MapMarker {
                markerView.injection(with: .init(
                    isSelected: true,
                    isCluster: false,
                    count: stores.count
                ))
            }
            tooltipView.selectStore(at: index)
            Logger.log(message: """
                툴팁 선택:
                - 선택된 스토어: \(stores[index].name)
                - 툴팁 인덱스: \(index)
                """, category: .debug)
        }

        // 툴팁 위치 설정 (예시: 마커 우측에 위치)
        let markerPoint = self.mainView.mapView.projection.point(for: marker.position)
        let markerHeight = (marker.iconView as? MapMarker)?.imageView.frame.height ?? 32
        tooltipView.frame = CGRect(
            x: markerPoint.x , // 마커 오른쪽 10포인트
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
        mainView.mapView.delegate = self

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
                guard let self = self,
                      let location = self.locationManager.location else { return }

                let camera = GMSCameraPosition.camera(
                    withLatitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    zoom: 15
                )
                self.mainView.mapView.animate(to: camera)
            }
            .disposed(by: disposeBag)
    




        mainView.filterChips.onRemoveLocation = { [weak self] in
            guard let self = self else { return }
            // 필터 제거 액션
            self.reactor?.action.onNext(.clearFilters(.location))

            // 현재 뷰포트의 바운드로 마커 업데이트 요청
            let bounds = self.mainView.mapView.projection.visibleRegion()
            self.reactor?.action.onNext(.viewportChanged(
                northEastLat: bounds.farRight.latitude,
                northEastLon: bounds.farRight.longitude,
                southWestLat: bounds.nearLeft.latitude,
                southWestLon: bounds.nearLeft.longitude
            ))

            self.clearAllMarkers()
               self.clusterMarkerDictionary.values.forEach { $0.map = nil }
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
            let bounds = self.mainView.mapView.projection.visibleRegion()
            self.reactor?.action.onNext(.viewportChanged(
                northEastLat: bounds.farRight.latitude,
                northEastLon: bounds.farRight.longitude,
                southWestLat: bounds.nearLeft.latitude,
                southWestLon: bounds.nearLeft.longitude
            ))

            // **(추가)** 선택된 마커 및 툴팁, 캐러셀을 완전히 해제
            self.resetSelectedMarker()

            // 만약 지도 위 마커를 전부 제거하고 싶다면 (상황에 따라)
            // self.clearAllMarkers()
            // self.clusterMarkerDictionary.values.forEach { $0.map = nil }
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
// 보류
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
                self.mainView.mapView.clear()
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

                // 만약 현재 선택된 마커의 스토어가 새로운 결과에 없다면, 선택 상태 초기화
                if let currentMarker = self.currentMarker,
                   let selectedStore = currentMarker.userData as? MapPopUpStore,
                   !results.contains(where: { $0.id == selectedStore.id }) {
                    self.resetSelectedMarker()
                }

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

         }


    func addMarker(for store: MapPopUpStore) {
          let marker = GMSMarker()
          marker.position = store.coordinate
          marker.userData = store

        marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)

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
                self.fetchStoreDetails(for: self.currentStores)



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

        // 트랜잭션 시작
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        switch level {
        case .detailed:
            // 현재 표시되어야 할 마커의 키 집합 생성
            let newStoreIds = Set(currentStores.map { $0.id })
            let groupedDict = groupStoresByExactLocation(currentStores)

            // 클러스터 마커는 모두 제거
            clusterMarkerDictionary.values.forEach { $0.map = nil }
            clusterMarkerDictionary.removeAll()

            // 그룹별로 마커 생성 또는 업데이트
            for (coordinate, storeGroup) in groupedDict {
                if storeGroup.count == 1, let store = storeGroup.first {
                    // 단일 스토어 마커
                    if let existingMarker = individualMarkerDictionary[store.id] {
                        // 기존 마커 재사용
                        if existingMarker.position != store.coordinate {
                            existingMarker.position = store.coordinate
                        }

                        // 마커 뷰 상태 업데이트 (필요한 경우에만)
                        if let markerView = existingMarker.iconView as? MapMarker,
                           markerView.currentInput?.isSelected != (existingMarker == currentMarker) {
                            markerView.injection(with: .init(
                                isSelected: (existingMarker == currentMarker),
                                isCluster: false
                            ))
                        }
                    } else {
                        // 새 마커 생성
                        let marker = GMSMarker(position: store.coordinate)
                        marker.userData = store
                        marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)

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
                    // 다중 스토어 마커
                    guard let firstStore = storeGroup.first else { continue }
                    let markerKey = firstStore.id

                    if let existingMarker = individualMarkerDictionary[markerKey] {
                        // 기존 마커 재사용
                        existingMarker.userData = storeGroup

                        if let markerView = existingMarker.iconView as? MapMarker,
                           markerView.currentInput?.count != storeGroup.count ||
                           markerView.currentInput?.isSelected != (existingMarker == currentMarker) {
                            markerView.injection(with: .init(
                                isSelected: (existingMarker == currentMarker),
                                isCluster: false,
                                count: storeGroup.count
                            ))
                        }
                    } else {
                        // 새 마커 생성
                        let marker = GMSMarker(position: firstStore.coordinate)
                        marker.userData = storeGroup
                        marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)

                        let markerView = MapMarker()
                        markerView.injection(with: .init(
                            isSelected: false,
                            isCluster: false,
                            count: storeGroup.count
                        ))
                        marker.iconView = markerView
                        marker.map = mainView.mapView

                        individualMarkerDictionary[markerKey] = marker
                    }
                }
            }

            individualMarkerDictionary = individualMarkerDictionary.filter { id, marker in
                if newStoreIds.contains(id) {
                    return true
                } else {
                    marker.map = nil
                    return false
                }
            }

        case .district, .city, .country:
            individualMarkerDictionary.values.forEach { $0.map = nil }
            individualMarkerDictionary.removeAll()

            // 클러스터 생성 및 업데이트
            let clusters = clusteringManager.clusterStores(currentStores, at: currentZoom)
            let activeClusterKeys = Set(clusters.map { $0.cluster.name })

            // 클러스터 마커 업데이트
            for cluster in clusters {
                let clusterKey = cluster.cluster.name

                if let existingMarker = clusterMarkerDictionary[clusterKey] {
                    // 기존 마커 재사용
                    if existingMarker.position != cluster.cluster.coordinate {
                        existingMarker.position = cluster.cluster.coordinate
                    }
                    existingMarker.userData = cluster

                    if let markerView = existingMarker.iconView as? MapMarker,
                       markerView.currentInput?.count != cluster.storeCount {
                        markerView.injection(with: .init(
                            isSelected: false,
                            isCluster: true,
                            regionName: cluster.cluster.name,
                            count: cluster.storeCount
                        ))
                    }
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

            // 더 이상 필요없는 클러스터 마커 제거
            clusterMarkerDictionary = clusterMarkerDictionary.filter { key, marker in
                if activeClusterKeys.contains(key) {
                    return true
                } else {
                    marker.map = nil
                    return false
                }
            }
        }

        CATransaction.commit()
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

        currentMarker?.map = nil
        currentMarker = nil
        carouselView.isHidden = true
        currentCarouselStores = []

        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 15
        )
        mainView.mapView.animate(to: camera)

        // 카메라 이동이 완료된 후 가장 가까운 스토어 찾기
        mainView.mapView.rx.idleAtPosition
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.findAndShowNearestStore(from: location)
            })
            .disposed(by: disposeBag)

        locationManager.stopUpdatingLocation()
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

        if let store = nearestStore {
            if let marker = findMarkerForStore(for: store) {
                _ = handleSingleStoreTap(marker, store: store)
            } else {
                let marker = GMSMarker()
                marker.position = store.coordinate
                marker.userData = store
                marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)

                let markerView = MapMarker()
                markerView.injection(with: .init(
                    isSelected: true,
                    isCluster: false,
                    count: 1
                ))
                marker.iconView = markerView
                marker.map = mainView.mapView

                // 마커를 individualMarkerDictionary에 추가
                individualMarkerDictionary[store.id] = marker

                currentMarker = marker
                carouselView.updateCards([store])
                currentCarouselStores = [store]
                carouselView.scrollToCard(index: 0)
                mainView.setStoreCardHidden(false, animated: true)
            }
        }
    }
}


// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let hitBoxSize: CGFloat = 44 // 터치 영역 크기
            let markerPoint = mapView.projection.point(for: marker.position)
            let touchPoint = mapView.projection.point(for: marker.position)

            let distance = sqrt(
                pow(markerPoint.x - touchPoint.x, 2) +
                pow(markerPoint.y - touchPoint.y, 2)
            )

            // 터치 영역을 벗어난 경우 무시
            if distance > hitBoxSize / 2 {
                return false
            }
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
    

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
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



    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture && !isMovingToMarker {
            resetSelectedMarker()
        }
    }
    /// 지도 빈 공간 탭 → 기존 마커/캐러셀 해제
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        guard !isMovingToMarker else { return }

        // 현재 선택된 마커의 상태를 완전히 초기화
        if let currentMarker = currentMarker {
            if let markerView = currentMarker.iconView as? MapMarker {
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: false,
                    count: (currentMarker.userData as? [MapPopUpStore])?.count ?? 1
                ))
            }
            currentMarker.map = nil
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




    // MARK: - Helper for single marker tap
     func handleSingleStoreTap(_ marker: GMSMarker, store: MapPopUpStore) -> Bool {
        if currentMarker == marker {
            resetSelectedMarker()
            return false
        }

        isMovingToMarker = true
        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil

        // 기존 마커 상태 업데이트
        if let previousMarker = currentMarker,
           let previousMarkerView = previousMarker.iconView as? MapMarker {
            previousMarkerView.injection(with: .init(
                isSelected: false,
                isCluster: false,
                count: (previousMarker.userData as? [MapPopUpStore])?.count ?? 1
            ))
        }

        // 새 마커 상태 업데이트
        if let markerView = marker.iconView as? MapMarker {
            markerView.injection(with: .init(
                isSelected: true,
                isCluster: false,
                count: 1
            ))
        }

        currentMarker = marker

        // 캐러셀 업데이트
        carouselView.updateCards([store])
        carouselView.isHidden = false
        currentCarouselStores = [store]
        carouselView.scrollToCard(index: 0)
        mainView.setStoreCardHidden(false, animated: true)

        mainView.mapView.animate(toLocation: marker.position)
        
        return true
    }



     func handleRegionalClusterTap(_ marker: GMSMarker, clusterData: ClusterMarkerData) -> Bool {
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


     func handleMicroClusterTap(_ marker: GMSMarker, storeArray: [MapPopUpStore]) -> Bool {
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
            if let markerView = marker.iconView as? MapMarker {
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: false,
                    count: storeArray.count
                ))
            }

            currentMarker = nil
            isMovingToMarker = false  // 여기서 false로 설정
            return false
        }

        isMovingToMarker = true

        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil

        if let previousMarker = currentMarker,
           let previousMarkerView = previousMarker.iconView as? MapMarker {
            previousMarkerView.injection(with: .init(
                isSelected: false,
                isCluster: false,
                count: (previousMarker.userData as? [MapPopUpStore])?.count ?? 1
            ))
        }

        if let markerView = marker.iconView as? MapMarker {
            markerView.injection(with: .init(
                isSelected: true,
                isCluster: false,
                count: storeArray.count
            ))
        }
        currentMarker = marker

        currentCarouselStores = storeArray
        carouselView.updateCards(storeArray)
        carouselView.isHidden = false
        carouselView.scrollToCard(index: 0)

        mainView.setStoreCardHidden(false, animated: true)

        // 지도 이동 및 툴팁 생성
        mainView.mapView.animate(toLocation: marker.position)

        // 툴팁 생성을 idleAtPosition 이벤트까지 기다리지 않고 직접 호출
        if storeArray.count > 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                self.configureTooltip(for: marker, stores: storeArray)
                self.isMovingToMarker = false
            }
        }

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
        if let currentMarker = currentMarker,
           let markerView = currentMarker.iconView as? MapMarker {
            // 기존 마커뷰 재사용, 새로 생성하지 않음
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


}


extension MapViewController {
    func bindViewport(reactor: MapReactor) {
        let cameraObservable = Observable.merge([
            mainView.mapView.rx.didChangePosition,
            mainView.mapView.rx.idleAtPosition
        ])
        .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
        .map { [unowned self] in
            self.mainView.mapView.camera
        }

        let distinctCameraObservable = cameraObservable.distinctUntilChanged { (cam1, cam2) -> Bool in
            let loc1 = CLLocation(latitude: cam1.target.latitude, longitude: cam1.target.longitude)
            let loc2 = CLLocation(latitude: cam2.target.latitude, longitude: cam2.target.longitude)
            let distance = loc1.distance(from: loc2)
            return distance < 40
        }

        // 뷰포트가 변경될 때마다 액션 전달
        distinctCameraObservable
            .map { [unowned self] _ -> MapReactor.Action in
                let visibleRegion = self.mainView.mapView.projection.visibleRegion()
                return .viewportChanged(
                    northEastLat: visibleRegion.farRight.latitude,
                    northEastLon: visibleRegion.farRight.longitude,
                    southWestLat: visibleRegion.nearLeft.latitude,
                    southWestLon: visibleRegion.nearLeft.longitude
                )
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 현재 뷰포트 내의 스토어 업데이트 - 마커만 업데이트
        reactor.state
               .map { $0.viewportStores }
               .distinctUntilChanged()
               .filter { !$0.isEmpty }
               .take(1)  // 초기 1회만 실행
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


        reactor.state
              .map { $0.viewportStores }
              .distinctUntilChanged()
              .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
              .observe(on: MainScheduler.instance)
              .map { [unowned self] stores -> [MapPopUpStore] in
                  let visibleRegion = self.mainView.mapView.projection.visibleRegion()
                  let bounds = GMSCoordinateBounds(region: visibleRegion)

                  let filteredStores = stores.filter { store in
                      bounds.contains(CLLocationCoordinate2D(
                          latitude: store.latitude,
                          longitude: store.longitude
                      ))
                  }

                  if self.currentMarker == nil,
                     let location = self.locationManager.location,
                     self is FullScreenMapViewController {
                      (self as! FullScreenMapViewController).findAndShowNearestStore(from: location)
                  }

                  return filteredStores
              }
              .do(onNext: { [weak self] stores in
                  self?.currentStores = stores
                  self?.updateMapWithClustering()
              })
              .subscribe()
              .disposed(by: disposeBag)

      }
    private func fetchStoreDetails(for stores: [MapPopUpStore]) {
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

        // 우선 기본 정보로 리스트 업데이트
        self.storeListViewController.reactor?.action.onNext(.setStores(initialStoreItems))

        // 각 스토어의 상세 정보를 병렬로 가져와서 업데이트
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

    private func findMarkerForStore(for store: MapPopUpStore) -> GMSMarker? {
        if let marker = individualMarkerDictionary[store.id] {
            return marker
        }
        for marker in clusterMarkerDictionary.values {
            if let stores = (marker.userData as? [MapPopUpStore]),
               stores.contains(where: { $0.id == store.id }) {
                return marker
            }
        }

        return nil
    }

    
private func handleMarkerTap(_ marker: GMSMarker) -> Bool {
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
