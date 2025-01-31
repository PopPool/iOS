import CoreLocation

struct RegionCoordinate {
    static let seoul = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
    static let gyeonggi = CLLocationCoordinate2D(latitude: 37.4138, longitude: 127.5183)
    static let incheon = CLLocationCoordinate2D(latitude: 37.4563, longitude: 126.7052)
    static let daejeon = CLLocationCoordinate2D(latitude: 36.3504, longitude: 127.3845)
    static let gwangju = CLLocationCoordinate2D(latitude: 35.1595, longitude: 126.8526)
    static let daegu = CLLocationCoordinate2D(latitude: 35.8714, longitude: 128.6014)
    static let busan = CLLocationCoordinate2D(latitude: 35.1796, longitude: 129.0756)
    static let ulsan = CLLocationCoordinate2D(latitude: 35.5384, longitude: 129.3114)
    static let chungbuk = CLLocationCoordinate2D(latitude: 36.6357, longitude: 127.4914)
    static let chungnam = CLLocationCoordinate2D(latitude: 36.6588, longitude: 126.6728)
    static let sejong = CLLocationCoordinate2D(latitude: 36.4801, longitude: 127.2892)
    static let jeonbuk = CLLocationCoordinate2D(latitude: 35.7175, longitude: 127.1530)
    static let jeonnam = CLLocationCoordinate2D(latitude: 34.8679, longitude: 126.9910)
    static let gyeongbuk = CLLocationCoordinate2D(latitude: 36.4919, longitude: 128.8889)
    static let gyeongnam = CLLocationCoordinate2D(latitude: 35.4606, longitude: 128.2132)
    static let gangwon = CLLocationCoordinate2D(latitude: 37.8228, longitude: 128.1555)
    static let jeju = CLLocationCoordinate2D(latitude: 33.4890, longitude: 126.4983)
}
enum RegionType {
    case seoul
    case gyeonggi
    case metropolitan
    case province
}

struct RegionDefinitions {
    // 서울 클러스터
    static let seoulClusters: [RegionCluster] = [
        RegionCluster(
            name: "도봉/노원/강북/중랑",
            subRegions: ["도봉구", "노원구", "강북구", "중랑구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.6494, longitude: 127.0510),
            type: .seoul
        ),
        RegionCluster(
            name: "동대문/성북",
            subRegions: ["동대문구", "성북구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.5894, longitude: 127.0435),
            type: .seoul
        ),
        RegionCluster(
            name: "중구/종로",
            subRegions: ["중구", "종로구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.5738, longitude: 126.9861),
            type: .seoul
        ),
        RegionCluster(
            name: "성동/광진",
            subRegions: ["성동구", "광진구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.5509, longitude: 127.0403),
            type: .seoul
        ),
        RegionCluster(
            name: "송파/강동",
            subRegions: ["송파구", "강동구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.5145, longitude: 127.1058),
            type: .seoul
        ),
        RegionCluster(
            name: "동작/관악",
            subRegions: ["동작구", "관악구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.4959, longitude: 126.9410),
            type: .seoul
        ),
        RegionCluster(
            name: "서초/강남",
            subRegions: ["서초구", "강남구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.4959, longitude: 127.0664),
            type: .seoul
        ),
        RegionCluster(
            name: "은평/서대문/마포",
            subRegions: ["은평구", "서대문구", "마포구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.5744, longitude: 126.9185),
            type: .seoul
        ),
        RegionCluster(
            name: "영등포/구로",
            subRegions: ["영등포구", "구로구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.5162, longitude: 126.8968),
            type: .seoul
        ),
        RegionCluster(
            name: "용산",
            subRegions: ["용산구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.5384, longitude: 126.9654),
            type: .seoul
        ),
        RegionCluster(
            name: "양천/강서/금천",
            subRegions: ["양천구", "강서구", "금천구"],
            coordinate: CLLocationCoordinate2D(latitude: 37.5509, longitude: 126.8553),
            type: .seoul
        )
    ]

    // 경기도 클러스터
    static let gyeonggiClusters: [RegionCluster] = [
        RegionCluster(
            name: "포천/연천/동두천/양주",
            subRegions: ["포천시", "연천군", "동두천시", "양주시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.8859, longitude: 127.0543),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "의정부/구리/남양주",
            subRegions: ["의정부시", "구리시", "남양주시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.7358, longitude: 127.1422),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "파주/고양/가평",
            subRegions: ["파주시", "고양시", "가평군"],
            coordinate: CLLocationCoordinate2D(latitude: 37.7599, longitude: 126.7762),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "용인/화성/수원",
            subRegions: ["용인시", "화성시", "수원시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.2911, longitude: 127.0876),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "군포/의왕/과천/안양",
            subRegions: ["군포시", "의왕시", "과천시", "안양시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.3956, longitude: 126.9477),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "부천/광명/시흥/안산",
            subRegions: ["부천시", "광명시", "시흥시", "안산시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.4563, longitude: 126.8040),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "안성/평택/오산",
            subRegions: ["안성시", "평택시", "오산시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.0042, longitude: 127.2003),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "여주/양평/광주/이천",
            subRegions: ["여주시", "양평군", "광주시", "이천시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.2958, longitude: 127.5986),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "김포",
            subRegions: ["김포시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.6153, longitude: 126.7164),
            type: .gyeonggi
        ),
        RegionCluster(
            name: "성남/하남",
            subRegions: ["성남시", "하남시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.4517, longitude: 127.1486),
            type: .gyeonggi
        )
    ]

    // 광역시 및 기타 지역
    static let metropolitanClusters: [RegionCluster] = [
        RegionCluster(
            name: "인천",
            subRegions: ["인천광역시"],
            coordinate: CLLocationCoordinate2D(latitude: 37.4563, longitude: 126.7052),
            type: .metropolitan
        ),
        RegionCluster(
            name: "대전",
            subRegions: ["대전광역시"],
            coordinate: CLLocationCoordinate2D(latitude: 36.3504, longitude: 127.3845),
            type: .metropolitan
        ),
        RegionCluster(
            name: "광주",
            subRegions: ["광주광역시"],
            coordinate: CLLocationCoordinate2D(latitude: 35.1595, longitude: 126.8526),
            type: .metropolitan
        ),
        RegionCluster(
            name: "대구",
            subRegions: ["대구광역시"],
            coordinate: CLLocationCoordinate2D(latitude: 35.8714, longitude: 128.6014),
            type: .metropolitan
        ),
        RegionCluster(
            name: "부산",
            subRegions: ["부산광역시"],
            coordinate: CLLocationCoordinate2D(latitude: 35.1796, longitude: 129.0756),
            type: .metropolitan
        ),
        RegionCluster(
            name: "울산",
            subRegions: ["울산광역시"],
            coordinate: CLLocationCoordinate2D(latitude: 35.5384, longitude: 129.3114),
            type: .metropolitan
        )
    ]

    // 도 단위 지역
    static let provinceClusters: [RegionCluster] = [
        RegionCluster(
            name: "충북",
            subRegions: ["충청북도"],
            coordinate: CLLocationCoordinate2D(latitude: 36.6357, longitude: 127.4914),
            type: .province
        ),
        RegionCluster(
            name: "충남",
            subRegions: ["충청남도"],
            coordinate: CLLocationCoordinate2D(latitude: 36.6588, longitude: 126.6728),
            type: .province
        ),
        RegionCluster(
            name: "세종",
            subRegions: ["세종특별자치시"],
            coordinate: CLLocationCoordinate2D(latitude: 36.4801, longitude: 127.2892),
            type: .province
        ),
        RegionCluster(
            name: "전북",
            subRegions: ["전라북도"],
            coordinate: CLLocationCoordinate2D(latitude: 35.7175, longitude: 127.1530),
            type: .province
        ),
        RegionCluster(
            name: "전남",
            subRegions: ["전라남도"],
            coordinate: CLLocationCoordinate2D(latitude: 34.8679, longitude: 126.9910),
            type: .province
        ),
        RegionCluster(
            name: "경북",
            subRegions: ["경상북도"],
            coordinate: CLLocationCoordinate2D(latitude: 36.4919, longitude: 128.8889),
            type: .province
        ),
        RegionCluster(
            name: "경남",
            subRegions: ["경상남도"],
            coordinate: CLLocationCoordinate2D(latitude: 35.4606, longitude: 128.2132),
            type: .province
        ),
        RegionCluster(
            name: "강원",
            subRegions: ["강원도"],
            coordinate: CLLocationCoordinate2D(latitude: 37.8228, longitude: 128.1555),
            type: .province
        ),
        RegionCluster(
            name: "제주",
            subRegions: ["제주특별자치도"],
            coordinate: CLLocationCoordinate2D(latitude: 33.4890, longitude: 126.4983),
            type: .province
        )
    ]

    static var allClusters: [RegionCluster] {
        seoulClusters + gyeonggiClusters + metropolitanClusters + provinceClusters
    }
}
