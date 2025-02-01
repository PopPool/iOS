import CoreLocation

enum MapZoomLevel {
    case country     // 줌 레벨 7 이하
    case region      // 줌 레벨 7..<9
    case city        // 줌 레벨 9..<11
    case district    // 줌 레벨 11..<14
    case detailed    // 줌 레벨 14 이상

    static func getLevel(from zoom: Float) -> MapZoomLevel {
        switch zoom {
        case ..<7:    return .country
        case 7..<9:   return .region
        case 9..<11:  return .city
        case 11..<14: return .district
        default:      return .detailed
        }
    }
}


struct RegionCluster {
    let name: String
    let subRegions: [String]
    let coordinate: CLLocationCoordinate2D
    let type: RegionType

    var storeCount: Int = 0
    var stores: [MapPopUpStore] = []
}

struct ClusterMarkerData {
    let cluster: RegionCluster
    let storeCount: Int
    var isSelected: Bool = false
}
