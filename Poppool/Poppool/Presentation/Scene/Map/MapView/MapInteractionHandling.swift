import UIKit
import NMapsMap
import SnapKit

protocol MapInteractionHandling: AnyObject {
    var mainView: MapView { get }
        var currentMarker: NMFMarker? { get set }
        var currentStores: [MapPopUpStore] { get set }
        var currentCarouselStores: [MapPopUpStore] { get set }
        var isMovingToMarker: Bool { get set }
        var currentTooltipView: UIView? { get set }
        var currentTooltipStores: [MapPopUpStore] { get set }
        var currentTooltipCoordinate: NMGLatLng? { get set }
        var individualMarkerDictionary: [Int64: NMFMarker] { get set }
        var clusterMarkerDictionary: [String: NMFMarker] { get set }
        var clusteringManager: ClusteringManager { get }

    // 마커 관련 메서드
    func updateMarkerStyle(marker: NMFMarker, selected: Bool, isCluster: Bool, count: Int, regionName: String)
    func handleSingleStoreTap(_ marker: NMFMarker, store: MapPopUpStore) -> Bool
    func handleRegionalClusterTap(_ marker: NMFMarker, clusterData: ClusterMarkerData) -> Bool
    func handleMicroClusterTap(_ marker: NMFMarker, storeArray: [MapPopUpStore]) -> Bool

    // 제스처 관련 메서드
    func handleMapViewTap(_ gesture: UITapGestureRecognizer)
    func handlePanGesture(_ gesture: UIPanGestureRecognizer)

    // 툴팁 관련 메서드
    func configureTooltip(for marker: NMFMarker, stores: [MapPopUpStore])
    func updateTooltipPosition()

    // 헬퍼 메서드
    func getVisibleBounds() -> (northEast: NMGLatLng, southWest: NMGLatLng)
    func updateMapWithClustering()

    func groupStoresByExactLocation(_ stores: [MapPopUpStore]) -> [CoordinateKey: [MapPopUpStore]]
    func createClusterMarkerImage(regionName: String, count: Int) -> UIImage?

}
