import CoreLocation

enum MapZoomLevel {
    case country      // 줌 레벨 7 미만
    case city         // 줌 레벨 7..<10 → 시단위 클러스터링
    case district     // 줌 레벨 10..<11 → 구단위 클러스터링
    case detailed     // 줌 레벨 11 이상

    static func getLevel(from zoom: Float) -> MapZoomLevel {
        switch zoom {
        case ..<7:
            return .country
        case 7..<10:
            return .city       // 시단위 클러스터링 영역
        case 10..<11:
            return .district   // 구단위 클러스터링 영역
        default:
            return .detailed
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
