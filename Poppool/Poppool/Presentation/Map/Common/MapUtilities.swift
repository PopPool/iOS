import CoreLocation

public func extractCity(from address: String) -> String {
    let components = address.components(separatedBy: " ")
    guard let first = components.first else { return address }
    if first.contains("서울") {
        return "서울"
    } else if first.contains("경기") {
        return "경기"
    }
    return first
}

public let seoulNorthRegions: [String] = [
    "도봉구", "노원구", "강북구", "중랑구", "동대문구", "성북구", "은평구"
]
public let seoulSouthRegions: [String] = [
    "중구", "종로구", "성동구", "광진구", "송파구", "강동구",
    "동작구", "관악구", "서초구", "강남구", "영등포구", "구로구",
    "용산구", "양천구", "강서구", "금천구"
]

public let gyeonggiNorthRegions: [String] = [
    "의정부시", "구리시", "남양주시", "파주시", "고양시", "김포시"
]
public let gyeonggiSouthRegions: [String] = [
    "용인시", "화성시", "수원시", "안산시", "부천시", "의왕시", "과천시",
    "여주시", "양평군", "광주시", "이천시"
]

// RepresentativeScope 수정
public struct RepresentativeScope {
    public static let seoulNorth = (
        center: CLLocationCoordinate2D(latitude: 37.6020, longitude: 127.0350),
        radius: 3000.0
    )
    public static let seoulSouth = (
        center: CLLocationCoordinate2D(latitude: 37.4959, longitude: 127.0664), // 강남/서초 중심
        radius: 3000.0
    )

    // 경기 북부/남부 좌표 조정
    public static let gyeonggiNorth = (
        center: CLLocationCoordinate2D(latitude: 37.7358, longitude: 127.0346), // 의정부 중심
        radius: 4000.0
    )
    public static let gyeonggiSouth = (
        center: CLLocationCoordinate2D(latitude: 37.2911, longitude: 127.0876), // 용인/분당 중심
        radius: 4000.0
    )
}
