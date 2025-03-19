import NMapsMap

enum MapZoomLevel {
    case country
    case city
    case district
    case detailed

    static func getLevel(from zoom: Float) -> MapZoomLevel {
            let level: MapZoomLevel
            switch zoom {
            case ..<7:
                level = .country
            case 7..<10:
                level = .city
            case 10..<11:
                level = .district
            default:
                level = .detailed
            }
            Logger.log(message: "줌 레벨 계산: \(zoom) -> \(level)", category: .debug)
            return level
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
