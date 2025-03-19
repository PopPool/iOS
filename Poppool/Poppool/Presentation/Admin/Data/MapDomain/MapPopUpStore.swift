import Foundation
import CoreLocation
import NMapsMap

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

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

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
