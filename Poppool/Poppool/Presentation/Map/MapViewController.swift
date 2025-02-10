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
            // 예: 소수점 5자리 정도까지 반올림하여 int로 변환
            self.lat = Int(latitude * 1_000_00)
            self.lng = Int(longitude * 1_000_00)
        }
    }

    // (신규) 툴팁(팝업) 뷰를 담아둘 변수
    var currentTooltipView: UIView?
    var currentTooltipStores: [MapPopUpStore] = []
    var currentTooltipCoordinate: CLLocationCoordinate2D?

    // MARK: - Properties
    var currentCarouselStores: [MapPopUpStore] = []
    private var markerDictionary: [Int64: GMSMarker] = [:]
    // 개별 마커와 클러스터 마커를 각각 관리하는 딕셔너리
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        checkLocationAuthorization()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mainView.mapView.isMyLocationEnabled = true
//        mainView.mapView.settings.myLocationButton = true



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
            .take(1)
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
        let level = MapZoomLevel.getLevel(from: currentZoom)

        switch level {
        case .detailed:  // 개별 마커
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
                           marker.map = mainView.mapView
                       } else {
                           // 새 마커
                           let marker = GMSMarker()
                           marker.position = store.coordinate
                           marker.userData = store

                           let markerView = MapMarker()
                           markerView.injection(with: .init(isSelected: false, isCluster: false))
                           marker.iconView = markerView
                           marker.map = mainView.mapView

                           individualMarkerDictionary[store.id] = marker
                       }

                   } else {
                       // (C-2) 동일 좌표에 여러 개 → "마이크로 클러스터" 마커
                       // userData에 [MapPopUpStore] 통째로 넣어둠
                       guard let firstStore = storeGroup.first else { continue }

                       let markerKey = firstStore.id
                       if let existingMarker = individualMarkerDictionary[markerKey] {
                           existingMarker.position = firstStore.coordinate
                           existingMarker.map = mainView.mapView
                           existingMarker.userData = storeGroup
                           if let markerView = existingMarker.iconView as? MapMarker {
                               markerView.injection(with: .init(
                                   isSelected: false,
                                   isCluster: false,  // 기본 마커 유지
                                   regionName: "",
                                   count: storeGroup.count  // 뱃지에 표시될 숫자
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
        // 새 스토어 ID 집합 생성

        var newMarkerIDs = Set<Int64>()

        // 각 스토어에 대해 증분 업데이트
        for store in stores {
            newMarkerIDs.insert(store.id)
            if let marker = individualMarkerDictionary[store.id] {
                // 기존 마커의 위치 업데이트 (변화가 있을 때만)
                if marker.position.latitude != store.latitude || marker.position.longitude != store.longitude {
                    marker.position = store.coordinate
                }
                // 추가 상태 업데이트가 필요한 경우 이곳에서 처리 (예: 선택 상태 등)
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

        // 기존 마커 중 더 이상 보이지 않는 마커 제거
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
            let fixedCoordinate = clusterData.cluster.coordinate // ✅ 구 중심 고정

            if let marker = clusterMarkerDictionary[clusterKey] {
                // 기존 마커 위치를 변경하지 않음
                if marker.position.latitude != fixedCoordinate.latitude ||
                    marker.position.longitude != fixedCoordinate.longitude {
                    marker.position = fixedCoordinate
                }
            } else {
                let marker = GMSMarker()
                marker.position = fixedCoordinate // ✅ 구 단위 클러스터는 고정된 좌표 사용
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
            // Reactor에 필터 정보 업데이트
            self.reactor?.action.onNext(.updateBothFilters(
                locations: filterData.locations,
                categories: filterData.categories
            ))
            self.reactor?.action.onNext(.filterTapped(nil))

            // (2) 필터 변경 직후 “현재 뷰포트” 다시 요청
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
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        updateMapWithClustering()
        updateTooltipPosition()

    }
    
    /// 지도 빈 공간 탭 → 기존 마커/캐러셀 해제
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
    
    // MARK: - Helper for single marker tap
    private func handleSingleStoreTap(_ marker: GMSMarker, store: MapPopUpStore) -> Bool {

        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil

        if let previousMarker = currentMarker,
           let previousStores = previousMarker.userData as? [MapPopUpStore] {
            let markerView = MapMarker()
            markerView.injection(with: .init(
                isSelected: false,
                isCluster: false,
                count: previousStores.count  // count 정보 유지
            ))
            previousMarker.iconView = markerView
        }

        // 새 마커 강조
        let markerView = MapMarker()
          let storeCount = (marker.userData as? [MapPopUpStore])?.count ?? 1
          markerView.injection(with: .init(
              isSelected: true,
              isCluster: false,
              count: storeCount
          ))
          marker.iconView = markerView
          currentMarker = marker

        // (A) 캐러셀에 “뷰포트 내 스토어들” 전체 or 원하는 배열로 업데이트
        carouselView.updateCards(currentStores)
        carouselView.isHidden = currentStores.isEmpty
        self.currentCarouselStores = currentStores
        
        // (B) 탭한 마커에 해당하는 스토어 찾아 scroll
        if let idx = currentStores.firstIndex(where: { $0.id == store.id }) {
            carouselView.scrollToCard(index: idx)
        }
        
        return true
    }
    private func handleRegionalClusterTap(_ marker: GMSMarker, clusterData: ClusterMarkerData) -> Bool {
        let currentZoom = mainView.mapView.camera.zoom
        let currentLevel = MapZoomLevel.getLevel(from: currentZoom)

        switch currentLevel {
        case .city:  // 시 단위 클러스터
            // 구 단위 클러스터가 보이는 줌 레벨로 이동
            let districtZoomLevel: Float = 10.0
            let camera = GMSCameraPosition(target: marker.position, zoom: districtZoomLevel)
            mainView.mapView.animate(to: camera)

        case .district:  // 구 단위 클러스터
            // 바로 개별 마커가 보이는 줌 레벨로 이동
            let detailedZoomLevel: Float = 11.0
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
            // 1. 이전에 선택된 마커 해제
            if let previousMarker = currentMarker {
                let markerView = MapMarker()
                markerView.injection(with: .init(isSelected: false, isCluster: false))
                previousMarker.iconView = markerView
            }

            // 2. 이전 툴팁 제거
            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil

            // 3. 탭한 마커 강조
            let markerView = MapMarker()
            markerView.injection(with: .init(
                isSelected: true,
                isCluster: false,
                count: storeArray.count
            ))
            marker.iconView = markerView
            currentMarker = marker

            // 4. 툴팁 생성 (고정 너비, 동적 높이)
        let fixedWidth: CGFloat = 200
        let tooltipView = MarkerTooltipView()
        tooltipView.configure(with: storeArray)

        // Auto Layout을 사용하도록 설정 (프레임을 직접 설정하지 않고)
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
//        mainView.mapView.addSubview(tooltipView)

        // 강제로 레이아웃 업데이트
        tooltipView.setNeedsLayout()
        tooltipView.layoutIfNeeded()

        // systemLayoutSizeFitting을 사용해 자연스러운 크기 계산
        let targetSize = CGSize(width: fixedWidth, height: UIView.layoutFittingCompressedSize.height)
        let fittingSize = tooltipView.systemLayoutSizeFitting(targetSize,
                                                              withHorizontalFittingPriority: .required,
                                                              verticalFittingPriority: .fittingSizeLevel)

        // 계산된 크기를 이용해 프레임을 업데이트
        tooltipView.frame = CGRect(origin: .zero, size: CGSize(width: fixedWidth, height: fittingSize.height))
            // 5. 지도에 툴팁 추가 후, 마커 위치 기반으로 배치 (초기 위치)
            mainView.mapView.addSubview(tooltipView)
            updateTooltipPosition()  // 현재 마커의 위치를 기반으로 tooltipView의 frame.origin을 설정

            currentTooltipView = tooltipView
            currentTooltipStores = storeArray
            currentTooltipCoordinate = marker.position

            // 6. 캐러셀 업데이트 (기존 코드와 동일)
            carouselView.updateCards(storeArray)
            carouselView.isHidden = false
            currentCarouselStores = storeArray
            carouselView.scrollToCard(index: 0)

            return true
        }
    private func updateTooltipPosition() {
        guard let marker = currentMarker, let tooltip = currentTooltipView else { return }

        // marker.position은 기본적으로 마커의 bottom-center입니다.
        // 이를 기반으로 marker의 아이콘 뷰가 있다면, marker의 중심을 계산합니다.
        let markerPoint = mainView.mapView.projection.point(for: marker.position)
        var markerCenter = markerPoint
        if let iconView = marker.iconView {
            // 예를 들어, 아이콘 뷰의 높이의 절반만큼 위로 이동하여 marker의 중심을 구함
            markerCenter.y = markerPoint.y - iconView.bounds.height / 1.5
        }

        // 원하는 오프셋 값 설정
        // - offsetX: marker의 중심 기준 오른쪽으로 얼마만큼 이동할지 (예: 10포인트)
        // - offsetY: badge보다 더 위에 위치하도록 충분히 위쪽으로 (예: 20포인트)
        let offsetX: CGFloat = -10
        let offsetY: CGFloat = -6

        // tooltip의 frame.origin을 markerCenter를 기준으로 계산:
        // x: markerCenter.x + offsetX
        // y: markerCenter.y - tooltip.height - offsetY  (즉, tooltip이 marker center 위쪽에 위치)
        tooltip.frame.origin = CGPoint(
            x: markerCenter.x + offsetX,
            y: markerCenter.y - tooltip.frame.height - offsetY
        )
    }



}


extension MapViewController {
    func bindViewport(reactor: MapReactor) {
        let cameraObservable = mainView.mapView.rx.idleAtPosition
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { [unowned self] in
                self.mainView.mapView.camera
            }

        // 2. 이전 카메라와의 변화량(위도, 경도, 줌)이 작으면 업데이트하지 않습니다.
        let distinctCameraObservable = cameraObservable.distinctUntilChanged { (cam1, cam2) -> Bool in
            let latDiff = abs(cam1.target.latitude - cam2.target.latitude)
            let lonDiff = abs(cam1.target.longitude - cam2.target.longitude)
            let zoomDiff = abs(cam1.zoom - cam2.zoom)
            return latDiff < 0.05 && lonDiff < 0.05 && zoomDiff < 0.5
        }

        // 3. visibleRegion의 네 모서리 좌표를 사용하여 올바른 뷰포트 경계를 계산합니다.
        //    (회전된 지도에서도 네 모서리 모두 고려하여 북동(Northeast)와 남서(Southwest) 좌표를 구합니다.)
        let viewportActionObservable = distinctCameraObservable.map { [unowned self] _ -> MapReactor.Action? in
            let visibleRegion = self.mainView.mapView.projection.visibleRegion()
            // 네 모서리 좌표 배열
            let corners = [
                visibleRegion.nearLeft,
                visibleRegion.nearRight,
                visibleRegion.farLeft,
                visibleRegion.farRight
            ]
            // 위도와 경도의 최댓값 및 최솟값 계산
            let lats = corners.map { $0.latitude }
            let lons = corners.map { $0.longitude }
            let northEast = CLLocationCoordinate2D(latitude: lats.max() ?? 0, longitude: lons.max() ?? 0)
            let southWest = CLLocationCoordinate2D(latitude: lats.min() ?? 0, longitude: lons.min() ?? 0)

            return .viewportChanged(
                northEastLat: northEast.latitude,
                northEastLon: northEast.longitude,
                southWestLat: southWest.latitude,
                southWestLon: southWest.longitude
            )
        }
        .compactMap { $0 }

        // 4. 계산된 뷰포트 경계를 Reactor의 액션으로 바인딩합니다.
        viewportActionObservable
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

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




    private func findMarker(for store: MapPopUpStore) -> GMSMarker? {
        return markerDictionary[store.id]
    }
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
    func updateMarkers(with stores: [MapPopUpStore]) {
        var newMarkerIDs = Set<Int64>()

        // 각 스토어에 대해 마커 업데이트 혹은 생성
        for store in stores {
            newMarkerIDs.insert(store.id)
            if let marker = markerDictionary[store.id] {
                // 기존 마커의 위치나 상태가 변경되었는지 확인
                if marker.position.latitude != store.latitude || marker.position.longitude != store.longitude {
                    marker.position = store.coordinate
                }
                // 마커 상태(예: 선택 여부) 등도 업데이트 필요하면 여기서 처리
            } else {
                // 새 마커 생성
                let marker = GMSMarker(position: store.coordinate)
                marker.userData = store

                // 캐싱 또는 재사용 가능한 markerView를 사용하도록 개선 가능
                let markerView = MapMarker()
                markerView.injection(with: store.toMarkerInput())
                marker.iconView = markerView
                marker.map = mainView.mapView
                markerDictionary[store.id] = marker
            }
        }

        // 기존에 있던 마커 중 새로 전달된 스토어 목록에 없는 마커 제거
        for (id, marker) in markerDictionary {
            if !newMarkerIDs.contains(id) {
                marker.map = nil
                markerDictionary.removeValue(forKey: id)
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
