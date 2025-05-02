import DomainInterface
import Infrastructure

import NMapsMap

class ClusteringManager {
    private let regions = RegionType.RegionDefinitions.allClusters

    private class MutableCluster {
        let base: RegionCluster
        var stores: [MapPopUpStore]
        var storeCount: Int
        var fixedCenter: NMGLatLng?

        init(base: RegionCluster, fixedCenter: NMGLatLng? = nil) {
            self.base = base
            self.stores = []
            self.storeCount = 0
            self.fixedCenter = fixedCenter
        }

        func centerCoordinate() -> NMGLatLng {
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
            let seoulGyeonggiClusters = clusterByDistrict(seoulGyeonggiStores)
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

        let allClusters = RegionType.RegionDefinitions.metropolitanClusters + RegionType.RegionDefinitions.provinceClusters
        for cluster in allClusters {
            clusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }

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

    private func clusterByDistrict(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var seoulClusters: [String: MutableCluster] = [:]
        var gyeonggiClusters: [String: MutableCluster] = [:]
        var otherClusters: [String: MutableCluster] = [:]

        for cluster in RegionType.RegionDefinitions.seoulClusters {
            seoulClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }
        for cluster in RegionType.RegionDefinitions.gyeonggiClusters {
            gyeonggiClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }
        for cluster in RegionType.RegionDefinitions.metropolitanClusters {
            otherClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }
        for cluster in RegionType.RegionDefinitions.provinceClusters {
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
        for cluster in filtered {
            Logger.log("- \(cluster.base.name): \(cluster.storeCount)개 매장", category: .debug)
        }

        return filtered.map { $0.toMarkerData() }
    }

    private func clusterByProvince(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var clusters: [String: MutableCluster] = [:]
        for cluster in RegionType.RegionDefinitions.provinceClusters {
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
        return RegionType.RegionDefinitions.seoulClusters.first { cluster in
            cluster.subRegions.contains { district in
                address.contains(district)
            }
        }?.name
    }

    private func findMatchingGyeonggiCityName(in address: String) -> String? {
        return RegionType.RegionDefinitions.gyeonggiClusters.first { cluster in
            cluster.subRegions.contains { cityName in
                address.contains(cityName)
            }
        }?.name
    }

    private func findMatchingProvinceName(in address: String) -> String? {
        return RegionType.RegionDefinitions.provinceClusters.first { cluster in
            cluster.subRegions.contains { province in
                address.contains(province)
            }
        }?.name
    }

    private func getFixedCenterForCity(_ city: String) -> NMGLatLng? {
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
