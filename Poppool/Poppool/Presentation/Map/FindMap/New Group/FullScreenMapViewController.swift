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
   }

    override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)

        reactor.state
            .map { $0.searchResult }
            .distinctUntilChanged()
            .compactMap { $0 }
            .map { store -> (store: MapPopUpStore, coordinate: CLLocationCoordinate2D) in
                return (
                    store: store,
                    coordinate: CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                )
            }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] data in
                guard let self = self else { return }

                // 기존 마커 제거
                self.mainView.mapView.clear()

                // 새 마커 추가
                let marker = GMSMarker()
                marker.position = data.coordinate
                marker.userData = data.store

                // 마커 뷰 설정
                let markerView = MapMarker()
                markerView.injection(with: .init(isSelected: true))
                marker.iconView = markerView
                marker.map = self.mainView.mapView

                // 카메라 이동
                let camera = GMSCameraPosition.camera(
                    withLatitude: data.coordinate.latitude,
                    longitude: data.coordinate.longitude,
                    zoom: 16
                )
                self.mainView.mapView.animate(to: camera)

                // 캐러셀 업데이트
                self.carouselView.updateCards([data.store])
                self.carouselView.isHidden = false
            }
            .disposed(by: disposeBag)
    }

   override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.navigationBar.isHidden = false
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
