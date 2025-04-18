import CoreLocation
import NMapsMap
import RxCocoa
import RxSwift
import SnapKit
import UIKit

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
        // use full‑screen styler for marker appearance
        self.markerStyler = FullScreenMarkerStyler()
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

        let cameraUpdate = NMFCameraUpdate(scrollTo: position, zoomTo: 15.0)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.3
        mainView.mapView.moveCamera(cameraUpdate)

        if let existingMarker = initialMarker {
            if existingMarker.mapView == nil {
                existingMarker.mapView = mainView.mapView
            }

            existingMarker.iconImage = NMFOverlayImage(name: "TapMarker")
            existingMarker.width = 44
            existingMarker.height = 44
            existingMarker.anchor = CGPoint(x: 0.5, y: 1.0)

            currentMarker = existingMarker
        } else {
            let marker = NMFMarker()
            marker.position = position
            marker.iconImage = NMFOverlayImage(name: "TapMarker")
            marker.width = 44
            marker.height = 44
            marker.anchor = CGPoint(x: 0.5, y: 1.0)
            marker.userInfo = ["storeData": store]
            marker.mapView = mainView.mapView
            currentMarker = marker
        }

        // 마커 잠금 설정
        markerLocked = true

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

    // 맵뷰 탭 처리 오버라이드
    override func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        return
    }

    // 카메라 이동 시작 시 호출
    override func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        if isFullScreenMode && markerLocked {
            return
        }
        super.mapView(mapView, cameraWillChangeByReason: reason, animated: animated)
    }

    // 카메라 이동 중 호출
    override func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
        if isFullScreenMode && markerLocked {
            // 기존 동작을 방지하고 풀스크린 동작 수행
            return
        }
        super.mapView(mapView, cameraIsChangingByReason: reason)
    }
}
