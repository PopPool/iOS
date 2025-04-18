import UIKit
import NMapsMap
import ReactorKit

extension MapViewController: MapInteractionHandling {

    // MARK: - Marker Style Handler
    func updateMarkerStyle(
        marker: NMFMarker,
        selected: Bool,
        isCluster: Bool,
        count: Int = 1,
        regionName: String = ""
    ) {
        if selected {
            marker.width = 44
            marker.height = 44
            marker.iconImage = NMFOverlayImage(name: "TapMarker")
        } else if isCluster {
            marker.width = 36
            marker.height = 36
            marker.iconImage = NMFOverlayImage(name: "cluster_marker")
        } else {
            marker.width = 32
            marker.height = 32
            marker.iconImage = NMFOverlayImage(name: "Marker")
        }

        marker.captionText = ""

        marker.anchor = CGPoint(x: 0.5, y: 1.0)


    }
    @objc func handleMapViewTap(_ gesture: UITapGestureRecognizer) {
        guard !isMovingToMarker else { return }

        if let currentMarker = self.currentMarker {
            updateMarkerStyle(marker: currentMarker, selected: false, isCluster: false)
            self.currentMarker = nil
        }

        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil
        currentTooltipStores = []
        currentTooltipCoordinate = nil

        // 캐러셀 및 스토어 카드 숨김 처리
        carouselView.isHidden = true
        carouselView.updateCards([])
        currentCarouselStores = []
        mainView.setStoreCardHidden(true, animated: true)

        // 클러스터 업데이트 (필요 시 재설정)
        updateMapWithClustering()
    }

    // MARK: - Pan Gesture Handler
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            if let constraint = listViewTopConstraint {
                let currentOffset = constraint.layoutConstraints.first?.constant ?? 0
                let newOffset = currentOffset + translation.y
                let minOffset: CGFloat = filterContainerBottomY // 필터 컨테이너 바닥 높이
                let maxOffset: CGFloat = view.frame.height     // 최하단 위치
                let clampedOffset = min(max(newOffset, minOffset), maxOffset)

                constraint.update(offset: clampedOffset)
                gesture.setTranslation(.zero, in: view)

                if modalState == .top {
                    adjustMapViewAlpha(for: clampedOffset, minOffset: minOffset, maxOffset: maxOffset)
                }
            }
        case .ended:
            if let constraint = listViewTopConstraint {
                let currentOffset = constraint.layoutConstraints.first?.constant ?? 0
                let middleY = view.frame.height * 0.3
                let targetState: ModalState

                // 속도와 현재 오프셋에 따른 상태 결정
                if velocity.y > 500 {
                    targetState = .bottom
                } else if velocity.y < -500 {
                    targetState = .top
                } else if currentOffset < middleY * 0.7 {
                    targetState = .top
                } else if currentOffset < view.frame.height * 0.7 {
                    targetState = .middle
                } else {
                    targetState = .bottom
                }

                animateToState(targetState)
            }
        default:
            break
        }
    }

    // MARK: - Tooltip Handlers
    func configureTooltip(for marker: NMFMarker, stores: [MapPopUpStore]) {
        // 기존 툴팁 제거
        currentTooltipView?.removeFromSuperview()

        let tooltipView = MarkerTooltipView()
        tooltipView.configure(with: stores)
        tooltipView.selectStore(at: 0)

        let markerPoint = mainView.mapView.projection.point(from: marker.position)
        let markerHeight: CGFloat = 32

        tooltipView.frame = CGRect(
            x: markerPoint.x,
            y: markerPoint.y - markerHeight - tooltipView.frame.height - 14,
            width: tooltipView.frame.width,
            height: tooltipView.frame.height
        )

        tooltipView.onStoreSelected = { [weak self] index in
            guard let self = self, index < stores.count else { return }
            self.currentCarouselStores = stores
            self.carouselView.updateCards(stores)
            self.carouselView.scrollToCard(index: index)

            self.updateMarkerStyle(marker: marker, selected: true, isCluster: false, count: stores.count)
            tooltipView.selectStore(at: index)
        }

        mainView.addSubview(tooltipView)
        currentTooltipView = tooltipView
        currentTooltipStores = stores
        currentTooltipCoordinate = marker.position
    }

    func updateTooltipPosition() {
        guard let marker = currentMarker, let tooltip = currentTooltipView else { return }
        let markerPoint = mainView.mapView.projection.point(from: marker.position)
        var markerCenter = markerPoint
        markerCenter.y -= 20
        let offsetX: CGFloat = -10
        let offsetY: CGFloat = -10

        tooltip.frame.origin = CGPoint(
            x: markerCenter.x + offsetX,
            y: markerCenter.y - tooltip.frame.height - offsetY
        )
    }

    // MARK: - Store Selection Handlers
    func handleSingleStoreTap(_ marker: NMFMarker, store: MapPopUpStore) -> Bool {
        isMovingToMarker = true

        if let previousMarker = currentMarker {
            updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
        }

        updateMarkerStyle(marker: marker, selected: true, isCluster: false)
        currentMarker = marker

        if currentCarouselStores.isEmpty || !currentCarouselStores.contains(where: { $0.id == store.id }) {
            let bounds = getVisibleBounds()
            let visibleStores = currentStores.filter { store in
                let storePosition = NMGLatLng(lat: store.latitude, lng: store.longitude)
                return NMGLatLngBounds(southWest: bounds.southWest, northEast: bounds.northEast).contains(storePosition)
            }

            if !visibleStores.isEmpty {
                currentCarouselStores = visibleStores
                carouselView.updateCards(visibleStores)
                if let index = visibleStores.firstIndex(where: { $0.id == store.id }) {
                    carouselView.scrollToCard(index: index)
                }
            } else {
                currentCarouselStores = [store]
                carouselView.updateCards([store])
            }
        } else {
            if let index = currentCarouselStores.firstIndex(where: { $0.id == store.id }) {
                carouselView.scrollToCard(index: index)
            }
        }

        carouselView.isHidden = false
        mainView.setStoreCardHidden(false, animated: true)

        if let storeArray = marker.userInfo["storeData"] as? [MapPopUpStore], storeArray.count > 1 {
            configureTooltip(for: marker, stores: storeArray)
            if let index = storeArray.firstIndex(where: { $0.id == store.id }) {
                (currentTooltipView as? MarkerTooltipView)?.selectStore(at: index)
            }
        } else {
            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil
        }

        isMovingToMarker = false
        return true
    }

    func handleRegionalClusterTap(_ marker: NMFMarker, clusterData: ClusterMarkerData) -> Bool {
        let currentZoom = mainView.mapView.zoomLevel
        let currentLevel = MapZoomLevel.getLevel(from: Float(currentZoom))

        switch currentLevel {
        case .city:
            let districtZoomLevel: Double = 10.0
            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: districtZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
            mainView.mapView.moveCamera(cameraUpdate)
        case .district:
            let detailedZoomLevel: Double = 12.0
            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: detailedZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
            mainView.mapView.moveCamera(cameraUpdate)
        default:
            break
        }

        updateMarkersForCluster(stores: clusterData.cluster.stores)
        carouselView.updateCards(clusterData.cluster.stores)
        carouselView.isHidden = false
        currentCarouselStores = clusterData.cluster.stores
        return true
    }

    func handleMicroClusterTap(_ marker: NMFMarker, storeArray: [MapPopUpStore]) -> Bool {
        if currentMarker == marker {
            currentTooltipView?.removeFromSuperview()
            currentTooltipView = nil
            currentTooltipStores = []
            currentTooltipCoordinate = nil
            carouselView.isHidden = true
            carouselView.updateCards([])
            currentCarouselStores = []
            updateMarkerStyle(marker: marker, selected: false, isCluster: false, count: storeArray.count)
            currentMarker = nil
            isMovingToMarker = false
            return false
        }

        isMovingToMarker = true
        currentTooltipView?.removeFromSuperview()
        currentTooltipView = nil

        if let previousMarker = currentMarker {
            updateMarkerStyle(marker: previousMarker, selected: false, isCluster: false)
        }

        updateMarkerStyle(marker: marker, selected: true, isCluster: false, count: storeArray.count)
        currentMarker = marker

        currentCarouselStores = storeArray
        carouselView.updateCards(storeArray)
        carouselView.isHidden = false
        carouselView.scrollToCard(index: 0)

        mainView.setStoreCardHidden(false, animated: true)

        let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.3
        mainView.mapView.moveCamera(cameraUpdate)

        if storeArray.count > 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                self.configureTooltip(for: marker, stores: storeArray)
                self.isMovingToMarker = false
            }
        }

        return true
    }


    func getVisibleBounds() -> (northEast: NMGLatLng, southWest: NMGLatLng) {
        let mapBounds = mainView.mapView.contentBounds
        let northEast = NMGLatLng(lat: mapBounds.northEastLat, lng: mapBounds.northEastLng)
        let southWest = NMGLatLng(lat: mapBounds.southWestLat, lng: mapBounds.southWestLng)
        return (northEast: northEast, southWest: southWest)
    }

    func updateMapWithClustering() {
        let currentZoom = mainView.mapView.zoomLevel
        let level = MapZoomLevel.getLevel(from: Float(currentZoom))

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        switch level {
        case .detailed:
            // 상세 레벨에서는 개별 마커를 사용합니다.
            let newStoreIds = Set(currentStores.map { $0.id })
            let groupedDict = groupStoresByExactLocation(currentStores)

            // 클러스터 마커 제거
            clusterMarkerDictionary.values.forEach { $0.mapView = nil }
            clusterMarkerDictionary.removeAll()

            // 그룹별로 개별 마커 생성/업데이트
            for (coordinate, storeGroup) in groupedDict {
                if storeGroup.count == 1, let store = storeGroup.first {
                    if let existingMarker = individualMarkerDictionary[store.id] {
                        if existingMarker.position.lat != store.latitude ||
                            existingMarker.position.lng != store.longitude {
                            existingMarker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                        }
                        let isSelected = (existingMarker == currentMarker)
                        updateMarkerStyle(marker: existingMarker, selected: isSelected, isCluster: false)
                    } else {
                        let marker = NMFMarker()
                        marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                        marker.userInfo = ["storeData": store]
                        marker.anchor = CGPoint(x: 0.5, y: 1.0)
                        updateMarkerStyle(marker: marker, selected: false, isCluster: false)

                        // 직접 터치 핸들러 추가
                        marker.touchHandler = { [weak self] overlay in
                            guard let self = self, let tappedMarker = overlay as? NMFMarker else { return false }
                            return self.handleSingleStoreTap(tappedMarker, store: store)
                        }

                        marker.mapView = mainView.mapView
                        individualMarkerDictionary[store.id] = marker
                    }
                } else {
                    // 여러 스토어가 동일 위치에 있으면 단일 마커로 표시하면서 count 갱신
                    guard let firstStore = storeGroup.first else { continue }
                    let markerKey = firstStore.id
                    if let existingMarker = individualMarkerDictionary[markerKey] {
                        existingMarker.userInfo = ["storeData": storeGroup]
                        let isSelected = (existingMarker == currentMarker)
                        updateMarkerStyle(marker: existingMarker, selected: isSelected, isCluster: false, count: storeGroup.count)
                    } else {
                        let marker = NMFMarker()
                        marker.position = NMGLatLng(lat: firstStore.latitude, lng: firstStore.longitude)
                        marker.userInfo = ["storeData": storeGroup]
                        marker.anchor = CGPoint(x: 0.5, y: 1.0)
                        updateMarkerStyle(marker: marker, selected: false, isCluster: false, count: storeGroup.count)

                        // 직접 터치 핸들러 추가
                        marker.touchHandler = { [weak self] overlay in
                            guard let self = self, let tappedMarker = overlay as? NMFMarker else { return false }
                            return self.handleMicroClusterTap(tappedMarker, storeArray: storeGroup)
                        }

                        marker.mapView = mainView.mapView
                        individualMarkerDictionary[markerKey] = marker
                    }
                }
            }

            // 기존에 보이지 않는 개별 마커 제거
            individualMarkerDictionary = individualMarkerDictionary.filter { id, marker in
                if newStoreIds.contains(id) {
                    return true
                } else {
                    marker.mapView = nil
                    return false
                }
            }

        case .district, .city, .country:
            // 개별 마커 숨기기
            individualMarkerDictionary.values.forEach { $0.mapView = nil }
            individualMarkerDictionary.removeAll()

            // 클러스터 생성
            let clusters = clusteringManager.clusterStores(currentStores, at: Float(currentZoom))
            let activeClusterKeys = Set(clusters.map { $0.cluster.name })

            for cluster in clusters {
                let clusterKey = cluster.cluster.name
                var marker: NMFMarker
                if let existingMarker = clusterMarkerDictionary[clusterKey] {
                    marker = existingMarker
                    if marker.position.lat != cluster.cluster.coordinate.lat ||
                        marker.position.lng != cluster.cluster.coordinate.lng {
                        marker.position = NMGLatLng(lat: cluster.cluster.coordinate.lat, lng: cluster.cluster.coordinate.lng)
                    }
                } else {
                    marker = NMFMarker()
                    clusterMarkerDictionary[clusterKey] = marker
                }

                marker.position = NMGLatLng(lat: cluster.cluster.coordinate.lat, lng: cluster.cluster.coordinate.lng)
                marker.userInfo = ["clusterData": cluster]

                if let clusterImage = createClusterMarkerImage(regionName: cluster.cluster.name, count: cluster.storeCount) {
                    marker.iconImage = NMFOverlayImage(image: clusterImage)
                } else {
                    marker.iconImage = NMFOverlayImage(name: "cluster_marker")
                }

                marker.touchHandler = { [weak self] (overlay) -> Bool in
                    guard let self = self,
                          let tappedMarker = overlay as? NMFMarker,
                          let clusterData = tappedMarker.userInfo["clusterData"] as? ClusterMarkerData else {
                        return false
                    }

                    return self.handleRegionalClusterTap(tappedMarker, clusterData: clusterData)
                }

                marker.captionText = ""
                marker.anchor = CGPoint(x: 0.5, y: 0.5)
                marker.mapView = mainView.mapView
            }

            // 활성 클러스터가 아닌 마커 제거
            for (key, marker) in clusterMarkerDictionary {
                if !activeClusterKeys.contains(key) {
                    marker.mapView = nil
                    clusterMarkerDictionary.removeValue(forKey: key)
                }
            }
        }

        CATransaction.commit()
    }
}
