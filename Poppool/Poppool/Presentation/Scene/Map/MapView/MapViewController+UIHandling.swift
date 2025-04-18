import NMapsMap
import ReactorKit
import UIKit

extension MapViewController {

    // MARK: - Map Alpha Handlers
    func adjustMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat) {
        let middleOffset = view.frame.height * 0.3
        if offset <= minOffset {
            mainView.mapView.alpha = 0 // 완전히 숨김
        } else if offset >= maxOffset {
            mainView.mapView.alpha = 1 // 완전히 보임
        } else if offset <= middleOffset {
            let progress = (offset - minOffset) / (middleOffset - minOffset)
            mainView.mapView.alpha = progress
        } else {
            mainView.mapView.alpha = 1
        }
    }

    func updateMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat) {
        let progress = (maxOffset - offset) / (maxOffset - minOffset)
        mainView.mapView.alpha = max(0, min(progress, 1))
    }

    // MARK: - Modal Animation Handler
    func animateToState(_ state: ModalState) {
        guard modalState != state else { return }
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            switch state {
            case .top:
                let filterChipsFrame = self.mainView.filterChips.convert(self.mainView.filterChips.bounds, to: self.view)
                self.mainView.mapView.alpha = 0
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

                if let reactor = self.reactor {
                    reactor.action.onNext(.fetchAllStores)
                    reactor.state
                        .map { $0.viewportStores }
                        .distinctUntilChanged()
                        .filter { !$0.isEmpty }
                        .take(1)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] stores in
                            self?.fetchStoreDetails(for: stores)
                        })
                        .disposed(by: self.disposeBag)
                }

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
        }
    }

    // MARK: - Helper Methods
    func setStoreCardHidden(_ hidden: Bool, animated: Bool) {
        mainView.setStoreCardHidden(hidden, animated: animated)
    }

    func updateMarkersForCluster(stores: [MapPopUpStore]) {
        for marker in individualMarkerDictionary.values {
            marker.mapView = nil
        }
        individualMarkerDictionary.removeAll()

        for marker in clusterMarkerDictionary.values {
            marker.mapView = nil
        }
        clusterMarkerDictionary.removeAll()

        for store in stores {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
            marker.userInfo = ["storeData": store]
            marker.anchor = CGPoint(x: 0.5, y: 1.0)

            updateMarkerStyle(marker: marker, selected: false, isCluster: false)

            marker.touchHandler = { [weak self] overlay in
                guard let self = self,
                      let tappedMarker = overlay as? NMFMarker,
                      let storeData    = tappedMarker.userInfo["storeData"] as? MapPopUpStore
                else { return false }
                return self.handleSingleStoreTap(tappedMarker, store: storeData)
            }

            marker.mapView = mainView.mapView
            individualMarkerDictionary[store.id] = marker
        }
    }

    // MARK: - Toast Helper
    func showNoMarkersToast() {
        Logger.log(message: "현재 지도 영역에 표시할 마커가 없습니다", category: .debug)
    }
}
