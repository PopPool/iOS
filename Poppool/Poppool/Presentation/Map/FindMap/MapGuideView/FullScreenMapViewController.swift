import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NMapsMap
import CoreLocation

class FullScreenMapViewController: MapViewController {
    // MARK: - Properties
    private var initialStore: MapPopUpStore?
    private var isFullScreenMode = true  // 풀스크린 모드 플래그 추가
    private var markerLocked = false // 마커 상태 잠금 플래그
    private var initialMarker: NMFMarker?


    // MARK: - Initialization
    init(store: MapPopUpStore?, existingMarker: NMFMarker? = nil) {
        self.initialStore = store
        self.initialMarker = existingMarker
        super.init()
    }



    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFullScreenUI()
        setupNavigation()
//        configureInitialMapPosition()
        self.navigationController?.navigationBar.isHidden = false
        Logger.log(message: "💡 초기 위치 구성 직전: initialStore=\(String(describing: initialStore?.name))", category: .debug)
        configureInitialMapPosition()


        Logger.log(message: "✅ FullScreenMapViewController - viewDidLoad 완료", category: .debug)

        mainView.mapView.touchDelegate = self
    }

    private func setupNavigation() {
        navigationItem.title = "찾아가는 길"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "bakcbutton")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        markerLocked = true  // 마커 상태 잠금
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        navigationItem.title = "찾아가는 길"
    }

    // MARK: - Setup
    private func setupFullScreenUI() {
        mainView.filterChips.isHidden = true
        mainView.listButton.isHidden = true
        mainView.locationButton.isHidden = true
        mainView.searchInput.isHidden = true
        carouselView.isHidden = false

        mainView.mapView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }

        carouselView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func configureInitialMapPosition() {
        guard let store = initialStore else { return }

        let position = NMGLatLng(lat: store.latitude, lng: store.longitude)

        // 카메라 이동
        let cameraUpdate = NMFCameraUpdate(scrollTo: position, zoomTo: 15.0)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.3
        mainView.mapView.moveCamera(cameraUpdate)

        // 기존 마커가 있으면 재활용
        if let existingMarker = initialMarker {
            // 기존 마커가 맵뷰에 설정되어 있지 않으면 설정
            if existingMarker.mapView == nil {
                existingMarker.mapView = mainView.mapView
            }

            // 마커 스타일 업데이트
            updateMarkerStyle(marker: existingMarker, selected: true, isCluster: false, count: 1)
            currentMarker = existingMarker
        } else {
            // 기존 마커가 없는 경우에만 새로 생성
            let marker = NMFMarker()
            marker.position = position
            marker.iconImage = NMFOverlayImage(name: "TapMarker")
            marker.width = 44
            marker.height = 44
            marker.anchor = CGPoint(x: 0.5, y: 1.0)
            marker.userInfo = ["storeData": store]
            marker.mapView = mainView.mapView
            currentMarker = marker

            // 마커 스타일 업데이트
            updateMarkerStyle(marker: marker, selected: true, isCluster: false, count: 1)
        }

        // 캐러셀 설정
        currentCarouselStores = [store]
        carouselView.updateCards([store])
        carouselView.isHidden = false
    }


    override func bind(reactor: MapReactor) {
        super.bind(reactor: reactor)

        // 캐러셀 상태 관찰
        carouselView.rx.observe(Bool.self, "isHidden")
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isHidden in
                if let isHidden = isHidden, isHidden == true, self?.isFullScreenMode == true {
                    // 풀스크린 모드에서 캐러셀이 숨겨진 경우 다시 표시
                    DispatchQueue.main.async {
                        self?.carouselView.isHidden = false
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    // 마커 스타일 업데이트 함수 - 항상 TapMarker로만 설정하도록 수정
    private func fullScreenUpdateMarkerStyle(marker: NMFMarker, selected: Bool) {
        // 선택 여부와 상관없이 항상 TapMarker
        marker.width = 44
        marker.height = 44
        marker.iconImage = NMFOverlayImage(name: "TapMarker")
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
    }

    override func updateMarkerStyle(marker: NMFMarker, selected: Bool, isCluster: Bool, count: Int = 1, regionName: String = "") {
        if selected {
            // 선택된 경우 항상 TapMarker
            marker.width = 44
            marker.height = 44
            marker.iconImage = NMFOverlayImage(name: "TapMarker")
        } else {
            // 선택되지 않은 경우 일반 마커
            marker.width = 32
            marker.height = 32
            marker.iconImage = NMFOverlayImage(name: "Marker")
        }
        marker.anchor = CGPoint(x: 0.5, y: 1.0)

        if count > 1 {
            marker.captionText = "\(count)"
        } else {
            marker.captionText = ""
        }
    }
    override func handleSingleStoreTap(_ marker: NMFMarker, store: MapPopUpStore) -> Bool {
        isMovingToMarker = true
        markerLocked = true  // 마커 상태 잠금

        // 이전 마커 선택 상태 해제
        if let previousMarker = currentMarker, previousMarker != marker {
            fullScreenUpdateMarkerStyle(marker: previousMarker, selected: false)
        }

        // 현재 마커를 TapMarker로 설정
        marker.iconImage = NMFOverlayImage(name: "TapMarker")
        marker.width = 44
        marker.height = 44
        fullScreenUpdateMarkerStyle(marker: marker, selected: true)
        currentMarker = marker

        // 캐러셀 업데이트 및 표시
        currentCarouselStores = [store]
        carouselView.updateCards([store])
        carouselView.isHidden = false
        mainView.setStoreCardHidden(false, animated: true)

        // 카메라 이동
        let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: 15.0)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.3
        mainView.mapView.moveCamera(cameraUpdate)

        // 약간의 지연 후 플래그 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isMovingToMarker = false
        }

        return true
    }

    // 맵뷰 탭 처리 오버라이드
    override func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // 풀스크린 모드에서는 맵 탭 시 아무 동작도 하지 않음 (캐러셀 유지)
        return
    }

    // 카메라 이동 시작 시 호출
    override func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        // 풀스크린 모드에서는 캐러셀 유지
        if isFullScreenMode && markerLocked {
            // 상위 클래스의 기본 동작 방지
            return
        }
        super.mapView(mapView, cameraWillChangeByReason: reason, animated: animated)
    }

    // 카메라 이동 중 호출
    override func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
        // 마커가 잠겨있을 때는 캐러셀 유지
        if isFullScreenMode && markerLocked {
            // 기존 동작을 방지하고 풀스크린 동작 수행
            return
        }
        super.mapView(mapView, cameraIsChangingByReason: reason)
    }

    override func handleRegionalClusterTap(_ marker: NMFMarker, clusterData: ClusterMarkerData) -> Bool {
        return false
    }

    override func handleMicroClusterTap(_ marker: NMFMarker, storeArray: [MapPopUpStore]) -> Bool {
        return false
    }
}
