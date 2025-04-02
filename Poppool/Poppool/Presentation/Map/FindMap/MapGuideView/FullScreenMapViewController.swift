import CoreLocation
import Foundation
import GoogleMaps
import ReactorKit
import RxSwift
import UIKit

final class FullScreenMapViewController: MapViewController {
    var selectedStore: MapPopUpStore?
    var shouldAutoSelectNearestStore = false  // 일반 모드와 다르게 false로 설정

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        setupNavigation()

        mainView.searchFilterContainer.isHidden = true
        mainView.filterChips.isHidden = true
        mainView.listButton.isHidden = true
        carouselView.isHidden = false

        // 지도 델리게이트 재설정
        mainView.mapView.delegate = self

        // 선택된 스토어가 있다면 즉시 마커 탭 처리 (요구사항 1)
        if let store = selectedStore {
            updateUI(for: store)
        }
    }

    // MARK: - Binding
    override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)

        // [변경] 기존 viewportStores 관련 바인딩은 풀스크린에서 marker tap 처리와 충돌할 수 있으므로 주석처리하거나 제거
        /*
        reactor.state
            .map { $0.viewportStores }
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] stores in
                self?.currentStores = stores
                self?.updateMapWithClustering()
            })
            .disposed(by: disposeBag)
        */

        // searchResult나 selectedStore 변경시에만 UI 업데이트 (요구사항 1)
        reactor.state
            .map { $0.selectedStore ?? $0.searchResult }
            .distinctUntilChanged { $0?.id == $1?.id }
            .compactMap { $0 }
            .filter { [weak self] store in
                // 현재 선택된 스토어와 다른 경우에만 업데이트
                self?.selectedStore?.id != store.id
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] store in
                self?.updateUI(for: store)
            })
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Map Delegate Methods
    override func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
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
        return false
    }

    override func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // 카메라 이동 중 별도 처리 없음
    }

    override func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // 지도 빈 공간 탭은 무시 
    }

    private func findMarkerForStore(for store: MapPopUpStore) -> GMSMarker? {
        if let marker = self.currentMarker,
           let markerStore = marker.userData as? MapPopUpStore,
           markerStore.id == store.id {
            return marker
        }
        return nil
    }

    /// 선택된 스토어 정보를 기반으로 마커, 카메라, 캐러셀을 업데이트 (요구사항 1)
    private func updateUI(for store: MapPopUpStore) {
        // 기존 마커 제거
        mainView.mapView.clear()

        // 새 마커 생성
        let marker = GMSMarker()
        marker.position = store.coordinate
        marker.userData = store
        marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)

        // 마커 뷰 생성 및 선택 상태 주입
        let selectedInput = MapMarker.Input(
            isSelected: true,
            isCluster: false,
            regionName: "",
            count: 1,
            isMultiMarker: false
        )
        let markerView = MapMarker()
        markerView.injection(with: selectedInput)
        marker.iconView = markerView

        // 마커를 지도에 추가
        marker.map = mainView.mapView
        currentMarker = marker

        mainView.mapView.selectedMarker = marker

        // 카메라 이동
        let camera = GMSCameraPosition.camera(
            withLatitude: store.latitude,
            longitude: store.longitude,
            zoom: 16
        )
        mainView.mapView.animate(to: camera)

        // 캐러셀 업데이트
        carouselView.updateCards([store])
        currentCarouselStores = [store]
        carouselView.isHidden = false

        // 약간의 딜레이 후 마커 뷰 재갱신 (필요 시)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            markerView.injection(with: selectedInput)
            markerView.setNeedsLayout()
            markerView.layoutIfNeeded()
        }
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true)
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
}
