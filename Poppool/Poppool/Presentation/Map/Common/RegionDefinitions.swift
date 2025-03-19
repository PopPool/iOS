import NMapsMap

struct RegionCoordinate {
    static let seoul = NMGLatLng(lat: 37.5665, lng: 126.9780)
    static let gyeonggi = NMGLatLng(lat: 37.4138, lng: 127.5183)
    static let incheon = NMGLatLng(lat: 37.4563, lng: 126.7052)
    static let daejeon = NMGLatLng(lat: 36.3504, lng: 127.3845)
    static let gwangju = NMGLatLng(lat: 35.1595, lng: 126.8526)
    static let daegu = NMGLatLng(lat: 35.8714, lng: 128.6014)
    static let busan = NMGLatLng(lat: 35.1796, lng: 129.0756)
    static let ulsan = NMGLatLng(lat: 35.5384, lng: 129.3114)
    static let chungbuk = NMGLatLng(lat: 36.6357, lng: 127.4914)
    static let chungnam = NMGLatLng(lat: 36.6588, lng: 126.6728)
    static let sejong = NMGLatLng(lat: 36.4801, lng: 127.2892)
    static let jeonbuk = NMGLatLng(lat: 35.7175, lng: 127.1530)
    static let jeonnam = NMGLatLng(lat: 34.8679, lng: 126.9910)
    static let gyeongbuk = NMGLatLng(lat: 36.4919, lng: 128.8889)
    static let gyeongnam = NMGLatLng(lat: 35.4606, lng: 128.2132)
    static let gangwon = NMGLatLng(lat: 37.8228, lng: 128.1555)
    static let jeju = NMGLatLng(lat: 33.4890, lng: 126.4983)
}

enum RegionType {
    case seoul
    case gyeonggi
    case metropolitan
    case province

    struct RegionDefinitions {
        // 서울 클러스터
        static let seoulClusters: [RegionCluster] = [
            RegionCluster(
                name: "도봉/노원/강북/중랑",
                subRegions: ["도봉구", "노원구", "강북구", "중랑구"],
                coordinate: NMGLatLng(lat: 37.6494, lng: 127.0510),
                type: .seoul
            ),
            RegionCluster(
                name: "동대문/성북",
                subRegions: ["동대문구", "성북구"],
                coordinate: NMGLatLng(lat: 37.5894, lng: 127.0435),
                type: .seoul
            ),
            RegionCluster(
                name: "중구/종로",
                subRegions: ["중구", "종로구"],
                coordinate: NMGLatLng(lat: 37.5738, lng: 126.9861),
                type: .seoul
            ),
            RegionCluster(
                name: "성동/광진",
                subRegions: ["성동구", "광진구"],
                coordinate: NMGLatLng(lat: 37.5509, lng: 127.0403),
                type: .seoul
            ),
            RegionCluster(
                name: "송파/강동",
                subRegions: ["송파구", "강동구"],
                coordinate: NMGLatLng(lat: 37.5145, lng: 127.1058),
                type: .seoul
            ),
            RegionCluster(
                name: "동작/관악",
                subRegions: ["동작구", "관악구"],
                coordinate: NMGLatLng(lat: 37.4959, lng: 126.9410),
                type: .seoul
            ),
            RegionCluster(
                name: "서초/강남",
                subRegions: ["서초구", "강남구"],
                coordinate: NMGLatLng(lat: 37.4959, lng: 127.0664),
                type: .seoul
            ),
            RegionCluster(
                name: "은평/서대문/마포",
                subRegions: ["은평구", "서대문구", "마포구"],
                coordinate: NMGLatLng(lat: 37.5744, lng: 126.9185),
                type: .seoul
            ),
            RegionCluster(
                name: "영등포/구로",
                subRegions: ["영등포구", "구로구"],
                coordinate: NMGLatLng(lat: 37.5162, lng: 126.8968),
                type: .seoul
            ),
            RegionCluster(
                name: "용산",
                subRegions: ["용산구"],
                coordinate: NMGLatLng(lat: 37.5384, lng: 126.9654),
                type: .seoul
            ),
            RegionCluster(
                name: "양천/강서/금천",
                subRegions: ["양천구", "강서구", "금천구"],
                coordinate: NMGLatLng(lat: 37.5509, lng: 126.8553),
                type: .seoul
            )
        ]

        // 경기도 클러스터
        static let gyeonggiClusters: [RegionCluster] = [
            RegionCluster(
                name: "포천/연천/동두천/양주",
                subRegions: ["포천시", "연천군", "동두천시", "양주시"],
                coordinate: NMGLatLng(lat: 37.8859, lng: 127.0543),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "의정부/구리/남양주",
                subRegions: ["의정부시", "구리시", "남양주시"],
                coordinate: NMGLatLng(lat: 37.7358, lng: 127.1422),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "파주/고양/가평",
                subRegions: ["파주시", "고양시", "가평군"],
                coordinate: NMGLatLng(lat: 37.7599, lng: 126.7762),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "용인/화성/수원",
                subRegions: ["용인시", "화성시", "수원시"],
                coordinate: NMGLatLng(lat: 37.2911, lng: 127.0876),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "군포/의왕/과천/안양",
                subRegions: ["군포시", "의왕시", "과천시", "안양시"],
                coordinate: NMGLatLng(lat: 37.3956, lng: 126.9477),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "부천/광명/시흥/안산",
                subRegions: ["부천시", "광명시", "시흥시", "안산시"],
                coordinate: NMGLatLng(lat: 37.4563, lng: 126.8040),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "안성/평택/오산",
                subRegions: ["안성시", "평택시", "오산시"],
                coordinate: NMGLatLng(lat: 37.0042, lng: 127.2003),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "여주/양평/광주/이천",
                subRegions: ["여주시", "양평군", "광주시", "이천시"],
                coordinate: NMGLatLng(lat: 37.2958, lng: 127.5986),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "김포",
                subRegions: ["김포시"],
                coordinate: NMGLatLng(lat: 37.6153, lng: 126.7164),
                type: .gyeonggi
            ),
            RegionCluster(
                name: "성남/하남",
                subRegions: ["성남시", "하남시"],
                coordinate: NMGLatLng(lat: 37.4517, lng: 127.1486),
                type: .gyeonggi
            )
        ]

        // 광역시 클러스터
        static let metropolitanClusters: [RegionCluster] = [
            RegionCluster(
                name: "인천",
                subRegions: ["인천광역시"],
                coordinate: NMGLatLng(lat: 37.4563, lng: 126.7052),
                type: .metropolitan
            ),
            RegionCluster(
                name: "대전",
                subRegions: ["대전광역시"],
                coordinate: NMGLatLng(lat: 36.3504, lng: 127.3845),
                type: .metropolitan
            ),
            RegionCluster(
                name: "광주",
                subRegions: ["광주광역시"],
                coordinate: NMGLatLng(lat: 35.1595, lng: 126.8526),
                type: .metropolitan
            ),
            RegionCluster(
                name: "대구",
                subRegions: ["대구광역시"],
                coordinate: NMGLatLng(lat: 35.8714, lng: 128.6014),
                type: .metropolitan
            ),
            RegionCluster(
                name: "부산",
                subRegions: ["부산광역시"],
                coordinate: NMGLatLng(lat: 35.1796, lng: 129.0756),
                type: .metropolitan
            ),
            RegionCluster(
                name: "울산",
                subRegions: ["울산광역시"],
                coordinate: NMGLatLng(lat: 35.5384, lng: 129.3114),
                type: .metropolitan
            )
        ]

        // 도 클러스터
        static let provinceClusters: [RegionCluster] = [
            RegionCluster(
                name: "충북",
                subRegions: ["충청북도"],
                coordinate: NMGLatLng(lat: 36.6357, lng: 127.4914),
                type: .province
            ),
            RegionCluster(
                name: "충남",
                subRegions: ["충청남도"],
                coordinate: NMGLatLng(lat: 36.6588, lng: 126.6728),
                type: .province
            ),
            RegionCluster(
                name: "세종",
                subRegions: ["세종특별자치시"],
                coordinate: NMGLatLng(lat: 36.4801, lng: 127.2892),
                type: .province
            ),
            RegionCluster(
                name: "전북",
                subRegions: ["전라북도"],
                coordinate: NMGLatLng(lat: 35.7175, lng: 127.1530),
                type: .province
            ),
            RegionCluster(
                name: "전남",
                subRegions: ["전라남도"],
                coordinate: NMGLatLng(lat: 34.8679, lng: 126.9910),
                type: .province
            ),
            RegionCluster(
                name: "경북",
                subRegions: ["경상북도"],
                coordinate: NMGLatLng(lat: 36.4919, lng: 128.8889),
                type: .province
            ),
            RegionCluster(
                name: "경남",
                subRegions: ["경상남도"],
                coordinate: NMGLatLng(lat: 35.4606, lng: 128.2132),
                type: .province
            ),
            RegionCluster(
                name: "강원",
                subRegions: ["강원도"],
                coordinate: NMGLatLng(lat: 37.8228, lng: 128.1555),
                type: .province
            ),
            RegionCluster(
                name: "제주",
                subRegions: ["제주특별자치도"],
                coordinate: NMGLatLng(lat: 33.4890, lng: 126.4983),
                type: .province
            )
        ]

        static var allClusters: [RegionCluster] {
            seoulClusters + gyeonggiClusters + metropolitanClusters + provinceClusters
        }
    }
}
