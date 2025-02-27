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
    private var isUserInteraction = false
    private var isMapMoving = false
    private var shouldUpdateCarouselAfterMoving = false


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
        }


        
        carouselView.rx.observe(Bool.self, "hidden")
               .distinctUntilChanged()
               .subscribe(onNext: { [weak self] isHidden in
                   guard let self = self, let isHidden = isHidden else { return }

                   // 캐러셀 상태 변경 시 마커 처리
                   self.hideMarkersUnderCarousel()
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
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                // 지도 움직임 상태 초기화
                self.isMapMoving = false

                // 현재 줌 레벨 확인
                let currentZoom = self.mainView.mapView.camera.zoom
                let level = MapZoomLevel.getLevel(from: currentZoom)

                // 개별 마커 레벨에서만 캐러셀 업데이트
                if level == .detailed {
                    // 마커 이동 중이 아닐 때만 뷰포트 기반 캐러셀 업데이트
                    if !self.isMovingToMarker {
                        // 현재 뷰포트 내 스토어 필터링
                        self.updateCarouselWithVisibleStores()
                    }

                    // 툴팁 위치 업데이트 - 다중 마커인 경우에만
                    if let marker = self.currentMarker,
                       let storeArray = marker.userData as? [MapPopUpStore],
                       storeArray.count > 1 {
                        if self.currentTooltipView == nil {
                            self.configureTooltip(for: marker, stores: storeArray)
                        } else {
                            self.updateTooltipPosition()
                        }
                    }
                } else {
                    // 클러스터 레벨에서는 캐러셀과 툴팁 숨김
                    self.carouselView.isHidden = true
                    self.carouselView.updateCards([])
                    self.currentCarouselStores = []
                    self.mainView.setStoreCardHidden(true, animated: true)

                    self.currentTooltipView?.removeFromSuperview()
                    self.currentTooltipView = nil
                    self.currentTooltipStores = []
                }

                self.isMovingToMarker = false
                self.isUserInteraction = false

                // 클러스터링 업데이트
                self.updateMapWithClustering()
                self.hideMarkersUnderCarousel()

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

            // 해당 스토어의 마커 찾기
            if let marker = self.findMarkerForStore(for: store) {
                // 이전 마커 선택 해제
                if let previousMarker = self.currentMarker,
                   previousMarker != marker,
                   let previousMarkerView = previousMarker.iconView as? MapMarker {
                    previousMarkerView.injection(with: .init(
                        isSelected: false,
                        isCluster: false,
                        count: (previousMarker.userData as? [MapPopUpStore])?.count ?? 1
                    ))
                }

                // 새 마커 선택
                if let markerView = marker.iconView as? MapMarker {
                    markerView.injection(with: .init(
                        isSelected: true,
                        isCluster: false,
                        count: (marker.userData as? [MapPopUpStore])?.count ?? 1
                    ))
                }

                // 현재 마커 업데이트
                self.currentMarker = marker

                // 지도 이동 코드 제거 - 캐러셀 스와이프 시 지도가 움직이지 않도록 함
                // self.mainView.mapView.animate(toLocation: marker.position)

                // 툴팁 처리 - 다중 마커인 경우에만
                if let storeArray = marker.userData as? [MapPopUpStore], storeArray.count > 1 {
                    // 툴팁 업데이트 또는 생성
                    if self.currentTooltipView == nil {
                        self.configureTooltip(for: marker, stores: storeArray)
                    }

                    // 현재 선택된 스토어에 맞게 툴팁 선택
                    if let tooltipIndex = storeArray.firstIndex(where: { $0.id == store.id }) {
                        (self.currentTooltipView as? MarkerTooltipView)?.selectStore(at: tooltipIndex)
                    }
                } else {
                    // 단일 마커면 툴팁 제거
                    self.currentTooltipView?.removeFromSuperview()
                    self.currentTooltipView = nil
                    self.currentTooltipStores = []
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

            // 툴팁에서 선택한 스토어
            let selectedStore = stores[index]

            // 캐러셀의 현재 내용이 이 다중 마커의 스토어들과 다르면 업데이트
            if self.currentCarouselStores != stores {
                self.currentCarouselStores = stores
                self.carouselView.updateCards(stores)
            }

            // 캐러셀에서 해당 스토어의 위치로 스크롤
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

        // 캐러셀 표시 여부를 줌 레벨에 따라 결정
        let shouldShowCarousel = (level == .detailed)

        // 캐러셀을 줌 레벨에 따라 표시/숨김
        if !shouldShowCarousel {
            carouselView.isHidden = true
            carouselView.updateCards([])
            currentCarouselStores = []
            mainView.setStoreCardHidden(true, animated: true)

            // 현재 툴팁도 해제
            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil
            currentTooltipStores = []

            // 선택된 마커도 해제
            if let currentMarker = currentMarker,
               let markerView = currentMarker.iconView as? MapMarker {
                markerView.injection(with: .init(
                    isSelected: false,
                    isCluster: false,
                    count: (currentMarker.userData as? [MapPopUpStore])?.count ?? 1
                ))
            }
            currentMarker = nil
        }

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

            // 더 이상 필요없는 마커 제거
            individualMarkerDictionary = individualMarkerDictionary.filter { id, marker in
                if newStoreIds.contains(id) {
                    return true
                } else {
                    marker.map = nil
                    return false
                }
            }

            // 개별 마커 레벨에서만 캐러셀 업데이트
            if shouldShowCarousel {
                // 선택된 마커가 없거나 이미 선택된 마커가 있지만 개별 마커인 경우만 캐러셀 업데이트
                if currentMarker == nil {
                    updateCarouselWithVisibleStores()
                } else if let userData = currentMarker?.userData {
                    if userData is MapPopUpStore || (userData as? [MapPopUpStore])?.count == 1 {
                        updateCarouselWithVisibleStores()
                    }
                }
            }

        case .district, .city, .country:
            // 개별 마커 제거
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
        hideMarkersUnderCarousel()

    }
    func hideMarkersUnderCarousel() {
        // 캐러셀이 숨겨져 있으면 모든 마커 표시
        if carouselView.isHidden {
            showAllMarkers()
            return
        }

        // 캐러셀의 지도 상 위치 계산 (상단 Y 좌표)
        let carouselTopY = view.frame.height - carouselView.frame.height - view.safeAreaInsets.bottom

        // 개별 마커 딕셔너리 처리
        for (id, marker) in individualMarkerDictionary {
            let markerPoint = mainView.mapView.projection.point(for: marker.position)
            let isUnderCarousel = markerPoint.y >= carouselTopY

            if isUnderCarousel {
                // 캐러셀 아래의 마커는 지도에서 완전히 제거
                marker.map = nil

                // 현재 선택된 마커가 캐러셀 아래에 있으면 툴팁도 제거
                if marker == currentMarker {
                    currentTooltipView?.removeFromSuperview()
                    currentTooltipView = nil
                    currentMarker = nil
                }
            } else {
                // 캐러셀 위의 마커는 표시
                if marker.map == nil {
                    marker.map = mainView.mapView
                }
            }
        }

        // 클러스터 마커 딕셔너리 처리
        for (key, marker) in clusterMarkerDictionary {
            let markerPoint = mainView.mapView.projection.point(for: marker.position)
            if markerPoint.y >= carouselTopY {
                marker.map = nil
            } else if marker.map == nil {
                marker.map = mainView.mapView
            }
        }

        // 일반 마커 딕셔너리 처리
        for (id, marker) in markerDictionary {
            let markerPoint = mainView.mapView.projection.point(for: marker.position)
            if markerPoint.y >= carouselTopY {
                marker.map = nil
            } else if marker.map == nil {
                marker.map = mainView.mapView
            }
        }

        // 툴팁 위치 확인 및 관리
        if let tooltipCoord = currentTooltipCoordinate {
            let tooltipMarkerPoint = mainView.mapView.projection.point(for: tooltipCoord)
            if tooltipMarkerPoint.y >= carouselTopY {
                currentTooltipView?.removeFromSuperview()
                currentTooltipView = nil
                currentTooltipCoordinate = nil
            }
        }
    }


    // 모든 마커를 표시하는 함수
    func showAllMarkers() {
        for (_, marker) in individualMarkerDictionary {
            marker.opacity = 1.0
        }

        for (_, marker) in clusterMarkerDictionary {
            marker.opacity = 1.0
        }

        for (_, marker) in markerDictionary {
            marker.opacity = 1.0
        }
    }
    private func clearAllMarkers() {
        // 개별 마커 제거
        individualMarkerDictionary.values.forEach { $0.map = nil }
        individualMarkerDictionary.removeAll()

        // 클러스터 마커 제거
        clusterMarkerDictionary.values.forEach { $0.map = nil }
        clusterMarkerDictionary.removeAll()

        // 일반 마커 제거
        markerDictionary.values.forEach { $0.map = nil }
        markerDictionary.removeAll()

        // 툴팁 제거
        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil
        currentTooltipStores = []
        currentTooltipCoordinate = nil

        // 선택된 마커 초기화
        currentMarker = nil
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

        // 이전 선택된 마커 초기화
        resetSelectedMarker()

        // 현재 위치로 카메라 이동
        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 15
        )
        mainView.mapView.animate(to: camera)

        // 카메라 이동이 완료된 후 뷰포트 내 스토어만 확인
        mainView.mapView.rx.idleAtPosition
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }

                // 뷰포트 내 스토어만 표시
                self.updateCarouselWithVisibleStores()
            })
            .disposed(by: disposeBag)

        locationManager.stopUpdatingLocation()
    }



    private func findAndShowNearestStore(from location: CLLocation) {
        guard !currentStores.isEmpty else {
            Logger.log(message: "현재위치 표기할 스토어가 없습니다", category: .debug)
            return
        }

        // 현재 뷰포트 내에 있는 스토어만 필터링
        let visibleRegion = mainView.mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)

        let visibleStores = currentStores.filter { store in
            bounds.contains(CLLocationCoordinate2D(
                latitude: store.latitude,
                longitude: store.longitude
            ))
        }

        // 뷰포트 내에 스토어가 있으면 뷰포트 내 스토어 표시
        if !visibleStores.isEmpty {
            // 뷰포트 내에서 가장 가까운 스토어 찾기
            let nearestVisibleStore = visibleStores.min { store1, store2 in
                let location1 = CLLocation(latitude: store1.latitude, longitude: store1.longitude)
                let location2 = CLLocation(latitude: store2.latitude, longitude: store2.longitude)
                return location.distance(from: location1) < location.distance(from: location2)
            }

            if let store = nearestVisibleStore,
               let marker = findMarkerForStore(for: store) {
                // 현재 뷰포트 내 가장 가까운 스토어의 마커 선택
                _ = handleSingleStoreTap(marker, store: store)
            }
        } else {
            // 뷰포트 내에 스토어가 없으면 토스트 메시지 표시
            showToast(message: "이 지역에는 팝업 스토어가 없어요")

            // 캐러셀 숨김
            carouselView.isHidden = true
            carouselView.updateCards([])
            currentCarouselStores = []
            mainView.setStoreCardHidden(true, animated: true)

            // 선택된 마커 초기화
            resetSelectedMarker()
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
        // 현재 줌 레벨 확인
        let currentZoomLevel = MapZoomLevel.getLevel(from: position.zoom)

        // 사용자 상호작용으로 인한 이동이고 마커 이동 중이 아닌 경우에만 처리
        if isUserInteraction && !isMovingToMarker {
            // 줌 레벨이 detailed가 아니면 캐러셀 숨김
            if currentZoomLevel != .detailed {
                carouselView.isHidden = true
                carouselView.updateCards([])
                currentCarouselStores = []
                mainView.setStoreCardHidden(true, animated: true)
                hideMarkersUnderCarousel()


                // 툴팁도 숨김
                currentTooltipView?.removeFromSuperview()
                currentTooltipView = nil
                currentTooltipStores = []
            }

            // 툴팁 위치 업데이트
            updateTooltipPosition()
        }

        // 지도 움직임 상태 업데이트
        isMapMoving = true
    }






    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        // 사용자 제스처로 인한 이동인 경우만 처리
        if gesture {
            isUserInteraction = true
            isMapMoving = true

            // 현재 줌 레벨이 개별 마커 레벨이 아니면 캐러셀 숨김
            let currentZoom = mapView.camera.zoom
            let level = MapZoomLevel.getLevel(from: currentZoom)

            if level != .detailed {
                carouselView.isHidden = true
                currentCarouselStores = []
                mainView.setStoreCardHidden(true, animated: true)
            }
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

        // 캐러셀 업데이트 - 뷰포트 내 모든 마커의 정보 표시
        updateCarouselWithVisibleStores()

        // 현재 선택된 스토어로 스크롤
        if let index = currentCarouselStores.firstIndex(where: { $0.id == store.id }) {
            carouselView.scrollToCard(index: index)
        }

        mainView.mapView.animate(toLocation: marker.position)

        return true
    }

    func handleRegionalClusterTap(_ marker: GMSMarker, clusterData: ClusterMarkerData) -> Bool {
        let currentZoom = mainView.mapView.camera.zoom
        let currentLevel = MapZoomLevel.getLevel(from: currentZoom)

        isMovingToMarker = true

        // 줌 레벨에 따른 처리
        switch currentLevel {
        case .country:
            // 국가 레벨에서 시 레벨로
            let cityZoomLevel: Float = 8.5
            let camera = GMSCameraPosition(target: marker.position, zoom: cityZoomLevel)
            mainView.mapView.animate(to: camera)

        case .city:
            // 시 레벨에서 구 레벨로
            let districtZoomLevel: Float = 10.5
            let camera = GMSCameraPosition(target: marker.position, zoom: districtZoomLevel)
            mainView.mapView.animate(to: camera)

        case .district:
            // 구 레벨에서 상세 레벨로 (해당 구의 스토어만 표시)
            let detailedZoomLevel: Float = 13.0
            let camera = GMSCameraPosition(target: marker.position, zoom: detailedZoomLevel)

            // 선택된 클러스터의 구 이름 가져오기
            let selectedDistrictName = clusterData.cluster.name
            Logger.log(message: "선택된 구: \(selectedDistrictName), 스토어 수: \(clusterData.storeCount), 상세 줌으로 확대", category: .debug)

            // 구 클러스터의 스토어들 저장
            let districtStores = clusterData.cluster.stores

            // 1. 기존 마커 초기화
            clearAllMarkers()

            // 2. 현재 스토어를 해당 구의 스토어로만 설정
            currentStores = districtStores

            // 3. 상세 줌 레벨로 애니메이션하며 이동
            mainView.mapView.animate(to: camera)

            // 4. 애니메이션이 완료되면 updateMapWithClustering이 호출되어
            // 스토어들이 개별 마커로 표시될 것임

        case .detailed:
            // 이미 상세 레벨인 경우, 아무 작업 없음
            break
        }

        // 클러스터 레벨에서는 캐러셀 표시하지 않음
        if currentLevel != .detailed {
            carouselView.isHidden = true
            carouselView.updateCards([])
            currentCarouselStores = []
            mainView.setStoreCardHidden(true, animated: true)
        }

        return true
    }

    func handleMicroClusterTap(_ marker: GMSMarker, storeArray: [MapPopUpStore]) -> Bool {
        // 이미 선택된 마커를 다시 탭할 때
        if currentMarker == marker {
            resetSelectedMarker()
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

        // 다중 마커의 경우 해당 마커의 스토어들만 표시 - 중요: isHidden을 false로 설정
        currentCarouselStores = storeArray
        carouselView.updateCards(storeArray)
        carouselView.isHidden = false  // 명시적으로 표시 설정
        carouselView.scrollToCard(index: 0)
        mainView.setStoreCardHidden(false, animated: true)

        // 지도 이동 및 툴팁 생성
        mainView.mapView.animate(toLocation: marker.position)

        // 툴팁 생성 - 약간의 지연을 두어 애니메이션이 완료된 후 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.configureTooltip(for: marker, stores: storeArray)
            self.isMovingToMarker = false
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

        // 현재 마커 참조 제거
        self.currentMarker = nil

        // 캐러셀 초기화 대신 뷰포트에 보이는 마커들로 업데이트
        updateCarouselWithVisibleStores()
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
        reactor.state
            .map { $0.viewportStores }
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] stores in
                guard let self = self else { return }

                // 현재 스토어 목록 업데이트 및 클러스터링
                self.currentStores = stores
                self.updateMapWithClustering()

                // 캐러셀 업데이트
                self.updateCarouselWithVisibleStores()
            })
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

                // 캐러셀 영역 계산
                let carouselTopY = self.view.frame.height - self.carouselView.frame.height - self.view.safeAreaInsets.bottom

                // 뷰포트 내에 있고 캐러셀 영역에 닿지 않는 스토어만 필터링
                let filteredStores = stores.filter { store in
                    // 뷰포트 내에 있는지 확인
                    let isInBounds = bounds.contains(CLLocationCoordinate2D(
                        latitude: store.latitude,
                        longitude: store.longitude
                    ))

                    // 캐러셀 아래에 있는지 확인
                    let markerPoint = self.mainView.mapView.projection.point(for: CLLocationCoordinate2D(
                        latitude: store.latitude,
                        longitude: store.longitude
                    ))
                    let isUnderCarousel = markerPoint.y >= carouselTopY

                    // 뷰포트 내에 있고 캐러셀 아래에 있지 않은 스토어만 반환
                    return isInBounds && !isUnderCarousel
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
        // 1. 개별 마커 딕셔너리에서 검색
        if let marker = individualMarkerDictionary[store.id] {
            return marker
        }

        // 2. 일반 마커 딕셔너리에서 검색 (추가됨)
        if let marker = markerDictionary[store.id] {
            return marker
        }

        // 3. 모든 마커 딕셔너리에서 다중 스토어로 저장된 마커 검색 (추가됨)
        for (_, marker) in individualMarkerDictionary {
            if let storeArray = marker.userData as? [MapPopUpStore],
               storeArray.contains(where: { $0.id == store.id }) {
                return marker
            }
        }

        // 4. 클러스터 마커에서 검색
        for (_, marker) in clusterMarkerDictionary {
            if let clusterData = marker.userData as? ClusterMarkerData,
               clusterData.cluster.stores.contains(where: { $0.id == store.id }) {
                return marker
            }
        }

        return nil
    }
    // 뷰포트 변경 시 캐러셀 업데이트
    func updateCarouselWithVisibleStores() {
        // 현재 줌 레벨 확인
        let currentZoom = mainView.mapView.camera.zoom
        let level = MapZoomLevel.getLevel(from: currentZoom)

        // 개별 마커 레벨이 아니면 캐러셀 숨김
        if level != .detailed {
            carouselView.isHidden = true
            carouselView.updateCards([])
            currentCarouselStores = []
            mainView.setStoreCardHidden(true, animated: true)
            return
        }

        // 현재 다중 마커가 선택된 상태이고 그 마커가 개별 마커 모음이면
        // 해당 마커의 스토어들만 표시 (단, 캐러셀 영역에 닿지 않는 스토어만)
        if let currentMarker = currentMarker,
           let storeArray = currentMarker.userData as? [MapPopUpStore],
           storeArray.count > 1 {
            // 캐러셀 영역 계산
            let carouselTopY = view.frame.height - carouselView.frame.height - view.safeAreaInsets.bottom

            // 캐러셀 영역에 닿지 않는 스토어만 필터링
            let visibleStores = storeArray.filter { store in
                let markerPoint = mainView.mapView.projection.point(for: CLLocationCoordinate2D(
                    latitude: store.latitude,
                    longitude: store.longitude
                ))
                return markerPoint.y < carouselTopY
            }

            if !visibleStores.isEmpty {
                currentCarouselStores = visibleStores
                carouselView.updateCards(visibleStores)
                carouselView.isHidden = false
                mainView.setStoreCardHidden(false, animated: true)
            } else {
                carouselView.isHidden = true
                carouselView.updateCards([])
                currentCarouselStores = []
                mainView.setStoreCardHidden(true, animated: true)
            }
            return
        }

        // 그 외에는 뷰포트에 보이는 모든 스토어 표시 (캐러셀 영역 제외)
        let visibleRegion = mainView.mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)

        // 캐러셀 영역 계산
        let carouselTopY = view.frame.height - carouselView.frame.height - view.safeAreaInsets.bottom

        // 캐러셀 아래에 있지 않은 스토어만 필터링
        let visibleStores = currentStores.filter { store in
            // 바운드 내에 있는지 확인
            let isInBounds = bounds.contains(CLLocationCoordinate2D(
                latitude: store.latitude,
                longitude: store.longitude
            ))

            // 캐러셀 아래에 있는지 확인
            let markerPoint = mainView.mapView.projection.point(for:
                CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude))
            let isUnderCarousel = markerPoint.y >= carouselTopY

            // 바운드 내에 있고 캐러셀 아래에 있지 않은 스토어만 반환
            return isInBounds && !isUnderCarousel
        }

        if !visibleStores.isEmpty {
            // 캐러셀 업데이트
            currentCarouselStores = visibleStores
            carouselView.updateCards(visibleStores)
            carouselView.isHidden = false
            mainView.setStoreCardHidden(false, animated: true)

            // 현재 선택된 마커가 있으면 해당 카드로 스크롤
            if let currentMarker = currentMarker {
                // 마커에서 스토어 정보 추출
                var selectedStore: MapPopUpStore? = nil

                if let store = currentMarker.userData as? MapPopUpStore {
                    selectedStore = store
                } else if let storeArray = currentMarker.userData as? [MapPopUpStore], !storeArray.isEmpty {
                    // 다중 마커의 경우 첫 번째 스토어 사용
                    selectedStore = storeArray.first
                }

                if let selectedStore = selectedStore,
                   let index = visibleStores.firstIndex(where: { $0.id == selectedStore.id }) {
                    carouselView.scrollToCard(index: index)
                }
            }
        } else {
            // 보이는 스토어가 없으면 캐러셀 숨김 및 토스트 메시지 표시
            carouselView.isHidden = true
            carouselView.updateCards([])
            currentCarouselStores = []
            mainView.setStoreCardHidden(true, animated: true)

            // 마커 이동 중이 아닐 때만 토스트 표시
            if !isMovingToMarker {
                showToast(message: "이 지역에는 팝업 스토어가 없어요")
            }
        }
    }

    private func showToast(message: String) {
        // 이미 표시 중인 토스트가 있으면 제거
        view.subviews.forEach { subview in
            if let label = subview as? UILabel, label.tag == 9999 {
                label.removeFromSuperview()
            }
        }

        let toastLabel = UILabel()
        toastLabel.tag = 9999 // 식별용 태그
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 18
        toastLabel.clipsToBounds = true

        view.addSubview(toastLabel)
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-80)
            make.width.lessThanOrEqualTo(280)
            make.height.equalTo(36)
        }

        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }

    // 마커에서 스토어 정보 추출 헬퍼 함수
    private func getStoreFromMarker(_ marker: GMSMarker) -> MapPopUpStore? {
        if let store = marker.userData as? MapPopUpStore {
            return store
        } else if let storeArray = marker.userData as? [MapPopUpStore], !storeArray.isEmpty {
            return storeArray.first
        } else if let clusterData = marker.userData as? ClusterMarkerData, !clusterData.cluster.stores.isEmpty {
            return clusterData.cluster.stores.first
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
