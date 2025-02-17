import Foundation
import UIKit
import RxSwift
import ReactorKit
import CoreLocation
import GoogleMaps

final class FullScreenMapViewController: MapViewController {
    var selectedStore: MapPopUpStore?

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
        if let store = selectedStore {
            updateUI(for: store)
        }

    }

    override func bind(reactor: Reactor) {
        let storeObservable = reactor.state
            .map { $0.selectedStore ?? $0.searchResult } // 선택된 스토어가 있으면 사용, 없으면 네트워크 결과 사용
            .distinctUntilChanged { $0?.id == $1?.id }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)

        storeObservable
            .subscribe(onNext: { [weak self] store in
                guard let self = self else { return }
                // 새 마커 생성 후 선택 상태로 표시
                let marker = GMSMarker()
                marker.position = store.coordinate
                marker.userData = store
                marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                let selectedInput = MapMarker.Input(isSelected: true,
                                                    isCluster: false,
                                                    regionName: "",
                                                    count: 1,
                                                    isMultiMarker: false)
                let markerView = MapMarker()
                markerView.injection(with: selectedInput)
                marker.iconView = markerView
//                self.mainView.mapView.clear()
                marker.map = self.mainView.mapView
                self.currentMarker = marker

                let camera = GMSCameraPosition.camera(withLatitude: store.latitude,
                                                      longitude: store.longitude,
                                                      zoom: 16)
                self.mainView.mapView.animate(to: camera)

                self.carouselView.updateCards([store])
                self.currentCarouselStores = [store]
                self.carouselView.isHidden = false
            })
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    // GMSMapViewDelegate 메서드들 override
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

        // 그 외
        return false
    }

    override func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // 뷰포트 변경 이벤트 중단
    }

    override func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // 지도 탭 이벤트 중단
    }

    private func findMarkerForStore(for store: MapPopUpStore) -> GMSMarker? {
        if let marker = self.currentMarker,
           let markerStore = marker.userData as? MapPopUpStore,
           markerStore.id == store.id {
            return marker
        }
        return nil
    }
    private func updateUI(for store: MapPopUpStore) {
        mainView.mapView.clear()

        let marker = GMSMarker()
        marker.position = store.coordinate
        marker.userData = store
        marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)

        let selectedInput = MapMarker.Input(isSelected: true,
                                            isCluster: false,
                                            regionName: "",
                                            count: 1,
                                            isMultiMarker: false)
        let markerView = MapMarker()
        markerView.injection(with: selectedInput)
        marker.iconView = markerView

        // 강제 레이아웃 갱신
        marker.iconView?.setNeedsLayout()
        marker.iconView?.layoutIfNeeded()

        marker.map = mainView.mapView
        currentMarker = marker

        let camera = GMSCameraPosition.camera(withLatitude: store.latitude,
                                              longitude: store.longitude,
                                              zoom: 16)
        mainView.mapView.animate(to: camera)

        carouselView.updateCards([store])
        currentCarouselStores = [store]
        carouselView.isHidden = false

        // 약간의 딜레이 후에도 재갱신 (수동 탭과 동일한 효과)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            markerView.injection(with: selectedInput)
            markerView.setNeedsLayout()
            markerView.layoutIfNeeded()
        }
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
}
