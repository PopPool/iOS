import Foundation
import UIKit
import RxSwift
import ReactorKit
import CoreLocation
import GoogleMaps

final class FullScreenMapViewController: MapViewController {

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
    }

//    override func bindViewport(reactor: MapReactor) {
//        // 뷰포트 바인딩 무시
//    }

    override func bind(reactor: Reactor) {
        reactor.state
            .map { $0.searchResult }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] store in
                guard let self = self else { return }

                // 기존 상태 초기화
                self.mainView.mapView.clear()
                self.currentMarker?.map = nil
                self.currentMarker = nil

                // 마커 설정
                let marker = GMSMarker()
                marker.position = store.coordinate
                marker.userData = store
                marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)

                let markerView = MapMarker()
                // store.mainImageUrl이 있다면 여기서 setPPImage를 사용하여 처리
                markerView.injection(with: .init(isSelected: true))
                marker.iconView = markerView
                marker.map = self.mainView.mapView
                self.currentMarker = marker

                // 카메라 이동
                let camera = GMSCameraPosition.camera(
                    withLatitude: store.latitude,
                    longitude: store.longitude,
                    zoom: 16
                )
                self.mainView.mapView.animate(to: camera)

                // 캐러셀 업데이트 - setPPImage 사용
                self.carouselView.updateCards([store])
                self.currentCarouselStores = [store]
                self.carouselView.isHidden = false
            }
            .disposed(by: disposeBag)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    // GMSMapViewDelegate 메서드들 override
    override func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true  // 마커 탭 이벤트 중단
    }

    override func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // 뷰포트 변경 이벤트 중단
    }

    override func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // 지도 탭 이벤트 중단
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
