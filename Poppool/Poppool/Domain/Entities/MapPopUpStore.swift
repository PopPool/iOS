import Foundation
import NMapsMap

// TODO: 프레젠테이션

// MARK: -  ddd

// FIXME: 엔티티 
struct MapPopUpStore: Equatable {
    let id: Int64
    let category: String
    let name: String
    let address: String
    let startDate: String
    let endDate: String
    let latitude: Double
    let longitude: Double
    let markerId: Int64
    let markerTitle: String
    let markerSnippet: String
    let mainImageUrl: String?

    //TODO:
    var nmgCoordinate: NMGLatLng {
        NMGLatLng(lat: latitude, lng: longitude)
    }

    func toMarkerInput() -> MapMarker.Input {
        return MapMarker.Input(
            isSelected: false,
            isCluster: false,
            regionName: self.markerTitle,
            count: 0
        )
    }

    func toStoreItem() -> StoreItem {
        return StoreItem(
            id: id,
            thumbnailURL: mainImageUrl ?? "",
            category: category,
            title: name,
            location: address,
            dateRange: "\(startDate) ~ \(endDate)",
            isBookmarked: false
        )
    }
}
