import NMapsMap
import UIKit

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

