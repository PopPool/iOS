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

        // partition() 호출 결과를 별도의 변수에 할당
        let partitionedStores = stores.partition { store in
            let city = extractCity(from: store.address)
            return city == "서울" || city == "경기"
        }
        let seoulGyeonggiStores = partitionedStores.0
        let otherStores = partitionedStores.1

        switch level {
        case .country:
            return clusterByProvince(stores)
        case .city:
            let seoulGyeonggiClusters = clusterByCityLevel(seoulGyeonggiStores)
            let otherClusters = clusterByMetropolitan(otherStores)
            return seoulGyeonggiClusters + otherClusters
        case .district:
            let seoulGyeonggiClusters = clusterByDistrict(seoulGyeonggiStores)
            let otherClusters = clusterByMetropolitan(otherStores)
            return seoulGyeonggiClusters + otherClusters
        case .detailed:
            return []
        }
    }

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

    private func clusterByCityLevel(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var clusters: [String: MutableCluster] = [:]

        // 서울/경기 클러스터 초기화
        initializeSeoulGyeonggiClusters(&clusters)

        for store in stores {
            let city = extractCity(from: store.address)
            let clusterKey = determineClusterKey(for: store, city: city, clusters: &clusters)
            if let cluster = clusters[clusterKey] {
                cluster.stores.append(store)
                cluster.storeCount += 1
            }
        }

        let validClusters = clusters.values.filter { $0.storeCount > 0 }
        return validClusters.map { $0.toMarkerData() }
    }

    private func initializeSeoulGyeonggiClusters(_ clusters: inout [String: MutableCluster]) {
        let predefinedClusters = [
            ("서울 북부", RepresentativeScope.seoulNorth.center),
            ("서울 남부", RepresentativeScope.seoulSouth.center),
            ("경기 북부", RepresentativeScope.gyeonggiNorth.center),
            ("경기 남부", RepresentativeScope.gyeonggiSouth.center)
        ]

        for (name, coordinate) in predefinedClusters {
            let baseRegion = RegionCluster(
                name: name,
                subRegions: [name],
                coordinate: coordinate,
                type: .metropolitan
            )
            clusters[name] = MutableCluster(base: baseRegion, fixedCenter: coordinate)
        }
    }

    private func determineClusterKey(for store: MapPopUpStore, city: String, clusters: inout [String: MutableCluster]) -> String {
        if city == "서울" {
            return seoulNorthRegions.contains(where: { store.address.contains($0) }) ? "서울 북부" : "서울 남부"
        } else if city == "경기" {
            return gyeonggiNorthRegions.contains(where: { store.address.contains($0) }) ? "경기 북부" : "경기 남부"
        } else {
            if clusters[city] == nil {
                if let coordinate = getFixedCenterForCity(city) {
                    let baseRegion = RegionCluster(
                        name: city,
                        subRegions: [city],
                        coordinate: coordinate,
                        type: .metropolitan
                    )
                    clusters[city] = MutableCluster(base: baseRegion, fixedCenter: coordinate)
                }
            }
            return city
        }
    }

    private func clusterByDistrict(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var seoulClusters: [String: MutableCluster] = [:]
        var gyeonggiClusters: [String: MutableCluster] = [:]
        var otherClusters: [String: MutableCluster] = [:]

        // 서울/경기 클러스터 초기화
        for cluster in RegionDefinitions.seoulClusters {
            seoulClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }
        for cluster in RegionDefinitions.gyeonggiClusters {
            gyeonggiClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }
        // 다른 지역 클러스터 초기화
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
