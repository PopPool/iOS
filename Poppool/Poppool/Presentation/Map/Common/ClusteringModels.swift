import NMapsMap

enum MapZoomLevel {
    case country
    case city
    case district
    case detailed

    static func getLevel(from zoom: Float) -> MapZoomLevel {
        switch zoom {
        case ..<7:
            return .country
        case 7..<10:
            return .city
        case 10..<11:
            return .district
        default:
            return .detailed
        }
    }
}

struct RegionCluster {
    let name: String
    let subRegions: [String]
    let coordinate: NMGLatLng
    let type: RegionType

    var storeCount: Int = 0
    var stores: [MapPopUpStore] = []
}

struct ClusterMarkerData {
    let cluster: RegionCluster
    let storeCount: Int
    var isSelected: Bool = false
}
