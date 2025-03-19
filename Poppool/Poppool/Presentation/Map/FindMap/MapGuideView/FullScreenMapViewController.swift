import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NMapsMap
import CoreLocation

class FullScreenMapViewController: MapViewController {
    // MARK: - Properties
    private var initialStore: MapPopUpStore?

    // MARK: - Initialization
    init(store: MapPopUpStore?) {
        self.initialStore = store
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFullScreenUI()
        configureInitialMapPosition()

        // 풀스크린 모드에서 별도 터치 델리게이트 설정
        mainView.mapView.touchDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
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

        // 닫기 버튼 추가
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        view.addSubview(closeButton)

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(44)
        }

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag) // 상위 클래스의 disposeBag 사용

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
        mainView.mapView.moveCamera(cameraUpdate)

        // 여기서 마커를 선택 상태로 추가
        let marker = NMFMarker()
        marker.position = position
        marker.userInfo = ["storeData": store]
        updateMarkerStyle(marker: marker, selected: true, isCluster: false) // 선택된 스타일 적용
        marker.mapView = mainView.mapView
        currentMarker = marker

        // 캐러셀 설정
        currentCarouselStores = [store]
        carouselView.updateCards([store])
        carouselView.isHidden = false
    }

    // MARK: - Override Methods
    override func bind(reactor: MapReactor) {
        super.bind(reactor: reactor)
        // 풀스크린 모드에서 추가 바인딩 필요 시 여기에 작성
    }

    override func handleSingleStoreTap(_ marker: NMFMarker, store: MapPopUpStore) -> Bool {
        isMovingToMarker = true

        if let previousMarker = currentMarker, previousMarker != marker {
            updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
        }

        updateMarkerStyle(marker: marker, selected: true, isCluster: false)
        currentMarker = marker

        currentCarouselStores = [store]
        carouselView.updateCards([store])
        carouselView.isHidden = false
        mainView.setStoreCardHidden(false, animated: true)

        let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: 15.0)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.3
        mainView.mapView.moveCamera(cameraUpdate)

        isMovingToMarker = false
        return true
    }

    override func handleRegionalClusterTap(_ marker: NMFMarker, clusterData: ClusterMarkerData) -> Bool {
        return false // 풀스크린에서는 클러스터 비활성화
    }

    override func handleMicroClusterTap(_ marker: NMFMarker, storeArray: [MapPopUpStore]) -> Bool {
        return false // 풀스크린에서는 마이크로 클러스터 비활성화
    }
}

// MARK: - NMFMapViewTouchDelegate
//extension FullScreenMapViewController: NMFMapViewTouchDelegate {
//    func mapView(_ mapView: NMFMapView, didTapOverlay overlay: NMFOverlay) -> Bool {
//        guard let marker = overlay as? NMFMarker,
//              let store = marker.userInfo["storeData"] as? MapPopUpStore else { return false }
//        return handleSingleStoreTap(marker, store: store)
//    }
//
//    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
//        // 풀스크린 모드에서는 지도 탭 시 동작 없음
//    }
//}
