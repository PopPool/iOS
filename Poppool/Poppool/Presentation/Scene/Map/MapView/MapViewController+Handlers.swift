//import UIKit
//import NMapsMap
//import ReactorKit
//
//extension MapViewController {
//
//    // MARK: - Marker Style Handler
//    func updateMarkerStyle(marker: NMFMarker, selected: Bool, isCluster: Bool, count: Int = 1, regionName: String = "") {
//        if selected {
//            marker.width = 44
//            marker.height = 44
//            marker.iconImage = NMFOverlayImage(name: "TapMarker")
//        } else if isCluster {
//            marker.width = 36
//            marker.height = 36
//            marker.iconImage = NMFOverlayImage(name: "cluster_marker")
//        } else {
//            marker.width = 32
//            marker.height = 32
//            marker.iconImage = NMFOverlayImage(name: "Marker")
//        }
//
//        marker.captionText = (count > 1) ? "\(count)" : ""
//        marker.anchor = CGPoint(x: 0.5, y: 1.0)
//    }
//
//    // MARK: - Map Tap Handler
//    @objc func handleMapViewTap(_ gesture: UITapGestureRecognizer) {
//        // 리스트 뷰가 보이는 상태가 아닌 경우에만 처리
//        guard !isMovingToMarker else { return }
//
//        // 선택된 마커 해제
//        if let currentMarker = self.currentMarker {
//            updateMarkerStyle(marker: currentMarker, selected: false, isCluster: false)
//            self.currentMarker = nil
//        }
//
//        // 툴팁 제거 및 관련 상태 초기화
//        currentTooltipView?.removeFromSuperview()
//        currentTooltipView = nil
//        currentTooltipStores = []
//        currentTooltipCoordinate = nil
//
//        // 캐러셀 및 스토어 카드 숨김 처리
//        carouselView.isHidden = true
//        carouselView.updateCards([])
//        currentCarouselStores = []
//        mainView.setStoreCardHidden(true, animated: true)
//
//        // 클러스터 업데이트 (필요 시 재설정)
//        updateMapWithClustering()
//    }
//
//    // MARK: - Pan Gesture Handler
//    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: view)
//        let velocity = gesture.velocity(in: view)
//
//        switch gesture.state {
//        case .changed:
//            if let constraint = listViewTopConstraint {
//                let currentOffset = constraint.layoutConstraints.first?.constant ?? 0
//                let newOffset = currentOffset + translation.y
//                let minOffset: CGFloat = filterContainerBottomY // 필터 컨테이너 바닥 높이
//                let maxOffset: CGFloat = view.frame.height     // 최하단 위치
//                let clampedOffset = min(max(newOffset, minOffset), maxOffset)
//
//                constraint.update(offset: clampedOffset)
//                gesture.setTranslation(.zero, in: view)
//
//                if modalState == .top {
//                    adjustMapViewAlpha(for: clampedOffset, minOffset: minOffset, maxOffset: maxOffset)
//                }
//            }
//        case .ended:
//            if let constraint = listViewTopConstraint {
//                let currentOffset = constraint.layoutConstraints.first?.constant ?? 0
//                let middleY = view.frame.height * 0.3
//                let targetState: ModalState
//
//                // 속도와 현재 오프셋에 따른 상태 결정
//                if velocity.y > 500 {
//                    targetState = .bottom
//                } else if velocity.y < -500 {
//                    targetState = .top
//                } else if currentOffset < middleY * 0.7 {
//                    targetState = .top
//                } else if currentOffset < view.frame.height * 0.7 {
//                    targetState = .middle
//                } else {
//                    targetState = .bottom
//                }
//
//                animateToState(targetState)
//            }
//        default:
//            break
//        }
//    }
//
//    // MARK: - Map Alpha Handlers
//    func adjustMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat) {
//        let middleOffset = view.frame.height * 0.3
//        if offset <= minOffset {
//            mainView.mapView.alpha = 0 // 완전히 숨김
//        } else if offset >= maxOffset {
//            mainView.mapView.alpha = 1 // 완전히 보임
//        } else if offset <= middleOffset {
//            let progress = (offset - minOffset) / (middleOffset - minOffset)
//            mainView.mapView.alpha = progress
//        } else {
//            mainView.mapView.alpha = 1
//        }
//    }
//
//    func updateMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat) {
//        let progress = (maxOffset - offset) / (maxOffset - minOffset)
//        mainView.mapView.alpha = max(0, min(progress, 1))
//    }
//
//    // MARK: - Modal Animation Handler
//    func animateToState(_ state: ModalState) {
//        guard modalState != state else { return }
//        self.view.layoutIfNeeded()
//        UIView.animate(withDuration: 0.3, animations: {
//            switch state {
//            case .top:
//                let filterChipsFrame = self.mainView.filterChips.convert(self.mainView.filterChips.bounds, to: self.view)
//                self.mainView.mapView.alpha = 0
//                self.storeListViewController.setGrabberHandleVisible(false)
//                self.listViewTopConstraint?.update(offset: filterChipsFrame.maxY)
//                self.mainView.searchInput.setBackgroundColor(.g50)
//
//            case .middle:
//                self.storeListViewController.setGrabberHandleVisible(true)
//                let offset = max(self.view.frame.height * 0.3, self.filterContainerBottomY)
//                self.listViewTopConstraint?.update(offset: offset)
//                self.storeListViewController.mainView.layer.cornerRadius = 20
//                self.storeListViewController.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//                self.mainView.mapView.alpha = 1
//                self.mainView.mapView.isHidden = false
//                self.mainView.searchInput.setBackgroundColor(.white)
//
//                if let reactor = self.reactor {
//                    reactor.action.onNext(.fetchAllStores)
//                    reactor.state
//                        .map { $0.viewportStores }
//                        .distinctUntilChanged()
//                        .filter { !$0.isEmpty }
//                        .take(1)
//                        .observe(on: MainScheduler.instance)
//                        .subscribe(onNext: { [weak self] stores in
//                            self?.fetchStoreDetails(for: stores)
//                        })
//                        .disposed(by: self.disposeBag)
//                }
//
//            case .bottom:
//                self.storeListViewController.setGrabberHandleVisible(true)
//                self.listViewTopConstraint?.update(offset: self.view.frame.height)
//                self.mainView.mapView.alpha = 1
//                self.mainView.mapView.isHidden = false
//                self.mainView.searchInput.setBackgroundColor(.white)
//            }
//            self.view.layoutIfNeeded()
//        }) { _ in
//            self.modalState = state
//        }
//    }
//
//    // MARK: - Tooltip & Marker Handlers
//
//    func configureTooltip(for marker: NMFMarker, stores: [MapPopUpStore]) {
//        // 기존 툴팁 제거
//        currentTooltipView?.removeFromSuperview()
//
//        let tooltipView = MarkerTooltipView()
//        tooltipView.configure(with: stores)
//        tooltipView.selectStore(at: 0)
//
//        let markerPoint = mainView.mapView.projection.point(from: marker.position)
//        let markerHeight: CGFloat = 32
//
//        tooltipView.frame = CGRect(
//            x: markerPoint.x,
//            y: markerPoint.y - markerHeight - tooltipView.frame.height - 14,
//            width: tooltipView.frame.width,
//            height: tooltipView.frame.height
//        )
//
//        mainView.addSubview(tooltipView)
//        currentTooltipView = tooltipView
//        currentTooltipStores = stores
//        currentTooltipCoordinate = marker.position
//    }
//
//    func updateTooltipPosition() {
//        guard let marker = currentMarker, let tooltip = currentTooltipView else { return }
//        let markerPoint = mainView.mapView.projection.point(from: marker.position)
//        var markerCenter = markerPoint
//        markerCenter.y -= 20
//        let offsetX: CGFloat = -10
//        let offsetY: CGFloat = -10
//
//        tooltip.frame.origin = CGPoint(
//            x: markerCenter.x + offsetX,
//            y: markerCenter.y - tooltip.frame.height - offsetY
//        )
//    }
//
//    // MARK: - Store Selection Handlers
//    func handleSingleStoreTap(_ marker: NMFMarker, store: MapPopUpStore) -> Bool {
//        isMovingToMarker = true
//
//        if let previousMarker = currentMarker {
//            updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
//        }
//
//        updateMarkerStyle(marker: marker, selected: true, isCluster: false)
//        currentMarker = marker
//
//        if currentCarouselStores.isEmpty || !currentCarouselStores.contains(where: { $0.id == store.id }) {
//            let bounds = getVisibleBounds()
//            let visibleStores = currentStores.filter { store in
//                let storePosition = NMGLatLng(lat: store.latitude, lng: store.longitude)
//                return NMGLatLngBounds(southWest: bounds.southWest, northEast: bounds.northEast).contains(storePosition)
//            }
//
//            if !visibleStores.isEmpty {
//                currentCarouselStores = visibleStores
//                carouselView.updateCards(visibleStores)
//                if let index = visibleStores.firstIndex(where: { $0.id == store.id }) {
//                    carouselView.scrollToCard(index: index)
//                }
//            } else {
//                currentCarouselStores = [store]
//                carouselView.updateCards([store])
//            }
//        } else {
//            if let index = currentCarouselStores.firstIndex(where: { $0.id == store.id }) {
//                carouselView.scrollToCard(index: index)
//            }
//        }
//
//        carouselView.isHidden = false
//        mainView.setStoreCardHidden(false, animated: true)
//
//        if let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore], storeArray.count > 1 {
//            configureTooltip(for: marker, stores: storeArray)
//            if let index = storeArray.firstIndex(where: { $0.id == store.id }) {
//                (currentTooltipView as? MarkerTooltipView)?.selectStore(at: index)
//            }
//        } else {
//            currentTooltipView?.removeFromSuperview()
//            currentTooltipView = nil
//        }
//
//        isMovingToMarker = false
//        return true
//    }
//
//    func handleRegionalClusterTap(_ marker: NMFMarker, clusterData: ClusterMarkerData) -> Bool {
//        let currentZoom = mainView.mapView.zoomLevel
//        let currentLevel = MapZoomLevel.getLevel(from: Float(currentZoom))
//
//        switch currentLevel {
//        case .city:
//            let districtZoomLevel: Double = 10.0
//            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: districtZoomLevel)
//            cameraUpdate.animation = .easeIn
//            cameraUpdate.animationDuration = 0.3
//            mainView.mapView.moveCamera(cameraUpdate)
//        case .district:
//            let detailedZoomLevel: Double = 12.0
//            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: detailedZoomLevel)
//            cameraUpdate.animation = .easeIn
//            cameraUpdate.animationDuration = 0.3
//            mainView.mapView.moveCamera(cameraUpdate)
//        default:
//            break
//        }
//
//        updateMarkersForCluster(stores: clusterData.cluster.stores)
//        carouselView.updateCards(clusterData.cluster.stores)
//        carouselView.isHidden = false
//        currentCarouselStores = clusterData.cluster.stores
//        return true
//    }
//
//    func handleMicroClusterTap(_ marker: NMFMarker, storeArray: [MapPopUpStore]) -> Bool {
//        if currentMarker == marker {
//            currentTooltipView?.removeFromSuperview()
//            currentTooltipView = nil
//            currentTooltipStores = []
//            currentTooltipCoordinate = nil
//            carouselView.isHidden = true
//            carouselView.updateCards([])
//            currentCarouselStores = []
//            updateMarkerStyle(marker: marker, selected: false, isCluster: false, count: storeArray.count)
//            currentMarker = nil
//            isMovingToMarker = false
//            return false
//        }
//
//        isMovingToMarker = true
//        currentTooltipView?.removeFromSuperview()
//        currentTooltipView = nil
//
//        if let previousMarker = currentMarker {
//            updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
//        }
//
//        updateMarkerStyle(marker: marker, selected: true, isCluster: false, count: storeArray.count)
//        currentMarker = marker
//
//        currentCarouselStores = storeArray
//        carouselView.updateCards(storeArray)
//        carouselView.isHidden = false
//        carouselView.scrollToCard(index: 0)
//
//        mainView.setStoreCardHidden(false, animated: true)
//
//        let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position)
//        cameraUpdate.animation = .easeIn
//        cameraUpdate.animationDuration = 0.3
//        mainView.mapView.moveCamera(cameraUpdate)
//
//        if storeArray.count > 1 {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                guard let self = self else { return }
//                self.configureTooltip(for: marker, stores: storeArray)
//                self.isMovingToMarker = false
//            }
//        }
//
//        return true
//    }
//
//    // MARK: - Toast Helper
//    private func showNoMarkersToast() {
//        Logger.log(message: "현재 지도 영역에 표시할 마커가 없습니다", category: .debug)
//    }
//}
