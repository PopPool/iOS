import CoreLocation
import UIKit

class ClusteringManager {
    private let regions = RegionDefinitions.allClusters

    private class MutableCluster {
        let base: RegionCluster
        var stores: [MapPopUpStore]
        var storeCount: Int
        var fixedCenter: CLLocationCoordinate2D?

        init(base: RegionCluster, fixedCenter: CLLocationCoordinate2D? = nil) {
            self.base = base
            self.stores = []
            self.storeCount = 0
            self.fixedCenter = fixedCenter
        }

        func centerCoordinate() -> CLLocationCoordinate2D {
            return fixedCenter ?? base.coordinate
        }

        func toMarkerData() -> ClusterMarkerData {
            let adjustedCluster = RegionCluster(
                name: base.name,
                subRegions: base.subRegions,
                coordinate: self.centerCoordinate(),
                type: base.type
            )
            return ClusterMarkerData(
                cluster: adjustedCluster,
                storeCount: storeCount
            )
        }
    }

    func clusterStores(_ stores: [MapPopUpStore], at zoomLevel: Float) -> [ClusterMarkerData] {
        let level = MapZoomLevel.getLevel(from: zoomLevel)

        // 모든 케이스에서 구 단위 클러스터링만 사용
        switch level {
        case .country, .city, .district:
            // 서울·경기와 그 외 지역 구분
            let partitionedStores = stores.partition { store in
                let city = extractCity(from: store.address)
                return city == "서울" || city == "경기"
            }
            let seoulGyeonggiStores = partitionedStores.0
            let otherStores = partitionedStores.1

            // 항상 구 단위로만 클러스터링
            let seoulGyeonggiClusters = clusterByDistrict(seoulGyeonggiStores)
            let otherClusters = clusterByMetropolitan(otherStores)
            return seoulGyeonggiClusters + otherClusters

        case .detailed:
            return []
        }
    }

    // MARK: - [수정] 단순 city명으로만 묶는 함수
    /// "서울 북부/남부", "경기 북부/남부" 대신 city명만으로 클러스터
    private func clusterByCityName(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var clusters: [String: MutableCluster] = [:]

        for store in stores {
            let city = extractCity(from: store.address)

            // 아직 해당 city 이름으로 된 MutableCluster가 없다면 생성
            if clusters[city] == nil {
                let baseRegion = RegionCluster(
                    name: city,
                    subRegions: [city],
                    coordinate: getFixedCenterForCity(city) ?? CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // 기본값(서울 좌표)
                    type: .metropolitan
                )
                clusters[city] = MutableCluster(base: baseRegion, fixedCenter: baseRegion.coordinate)
            }

            // 스토어 할당
            if let cluster = clusters[city] {
                cluster.stores.append(store)
                cluster.storeCount += 1
            }
        }

        let validClusters = clusters.values.filter { $0.storeCount > 0 }
        return validClusters.map { $0.toMarkerData() }
    }

    // 광역시·도 기준으로 묶는 로직은 기존과 동일
    private func clusterByMetropolitan(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var clusters: [String: MutableCluster] = [:]

        // 광역시/도 클러스터 초기화
        let allClusters = RegionDefinitions.metropolitanClusters + RegionDefinitions.provinceClusters
        for cluster in allClusters {
            clusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }

        // 스토어 할당
        for store in stores {
            let city = extractCity(from: store.address)
            if let cluster = clusters[city] {
                cluster.stores.append(store)
                cluster.storeCount += 1
            }
        }

        let validClusters = clusters.values.filter { $0.storeCount > 0 }
        return validClusters.map { $0.toMarkerData() }
    }

    // 서울·경기의 구/시 단위로 묶는 함수. 필요 시 북부/남부 구분 제거
    private func clusterByDistrict(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var seoulClusters: [String: MutableCluster] = [:]
        var gyeonggiClusters: [String: MutableCluster] = [:]
        var otherClusters: [String: MutableCluster] = [:]

        // 서울/경기 각 구/시 초기화
        for cluster in RegionDefinitions.seoulClusters {
            seoulClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }
        for cluster in RegionDefinitions.gyeonggiClusters {
            gyeonggiClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }

        // 그 외 지역
        for cluster in RegionDefinitions.metropolitanClusters {
            otherClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }
        for cluster in RegionDefinitions.provinceClusters {
            otherClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }

        for store in stores {
            let city = extractCity(from: store.address)
            switch city {
            case "서울":
                if let clusterName = findMatchingSeoulDistrictName(in: store.address),
                   let cluster = seoulClusters[clusterName] {
                    cluster.stores.append(store)
                    cluster.storeCount += 1
                }
            case "경기":
                if let clusterName = findMatchingGyeonggiCityName(in: store.address),
                   let cluster = gyeonggiClusters[clusterName] {
                    cluster.stores.append(store)
                    cluster.storeCount += 1
                }
            default:
                if let cluster = otherClusters[city] {
                    cluster.stores.append(store)
                    cluster.storeCount += 1
                }
            }
        }

        let combined = Array(seoulClusters.values) + Array(gyeonggiClusters.values) + Array(otherClusters.values)
        let filtered = combined.filter { $0.storeCount > 0 }
        return filtered.map { $0.toMarkerData() }
    }

    private func clusterByProvince(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var clusters: [String: MutableCluster] = [:]
        for cluster in RegionDefinitions.provinceClusters {
            clusters[cluster.name] = MutableCluster(base: cluster)
        }
        for store in stores {
            if let provinceName = findMatchingProvinceName(in: store.address),
               let cluster = clusters[provinceName] {
                cluster.stores.append(store)
                cluster.storeCount += 1
            }
        }
        let result = clusters.values.filter { $0.storeCount > 0 }
        return result.map { $0.toMarkerData() }
    }



    private func findMatchingSeoulDistrictName(in address: String) -> String? {
        return RegionDefinitions.seoulClusters.first { cluster in
            cluster.subRegions.contains { district in
                address.contains(district)
            }
        }?.name
    }

    private func findMatchingGyeonggiCityName(in address: String) -> String? {
        return RegionDefinitions.gyeonggiClusters.first { cluster in
            cluster.subRegions.contains { cityName in
                address.contains(cityName)
            }
        }?.name
    }

    private func findMatchingProvinceName(in address: String) -> String? {
        return RegionDefinitions.provinceClusters.first { cluster in
            cluster.subRegions.contains { province in
                address.contains(province)
            }
        }?.name
    }

    private func getFixedCenterForCity(_ city: String) -> CLLocationCoordinate2D? {
        switch city {
        case "대구": return RegionCoordinate.daegu
        case "부산": return RegionCoordinate.busan
        case "울산": return RegionCoordinate.ulsan
        case "대전": return RegionCoordinate.daejeon
        case "광주": return RegionCoordinate.gwangju
        case "인천": return RegionCoordinate.incheon
        case "세종": return RegionCoordinate.sejong
        default: return nil
        }
    }
}

// partition() 확장: 서울·경기 vs 그 외 지역 분류 용
extension Array {
    func partition(by predicate: (Element) -> Bool) -> ([Element], [Element]) {
        var matching: [Element] = []
        var nonMatching: [Element] = []
        for element in self {
            if predicate(element) {
                matching.append(element)
            } else {
                nonMatching.append(element)
            }
        }
        return (matching, nonMatching)
    }
}
