import CoreLocation

class ClusteringManager {
    private let regions = RegionDefinitions.allClusters

    // 클러스터링을 위한 가변 구조체
    private class MutableCluster {
        let base: RegionCluster
        var stores: [MapPopUpStore]
        var storeCount: Int

        init(base: RegionCluster) {
            self.base = base
            self.stores = []
            self.storeCount = 0
        }

        func toMarkerData() -> ClusterMarkerData {
            return ClusterMarkerData(
                cluster: base,
                storeCount: storeCount
            )
        }
    }

    func clusterStores(_ stores: [MapPopUpStore], at zoomLevel: Float) -> [ClusterMarkerData] {
        let level = MapZoomLevel.getLevel(from: zoomLevel)
        switch level {
        case .country:
            return clusterByProvince(stores)
        case .region:
            return clusterByRegion(stores)
        case .city, .district:
            return clusterByCity(stores)
        case .detailed:
            return []
        }
    }


    private func clusterByProvince(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var clusteredStores = initializeClusters(type: .province)

        for store in stores {
            if let cluster = findClusterForStore(store, in: clusteredStores) {
                cluster.stores.append(store)
                cluster.storeCount += 1
            }
        }

        return clusteredStores
            .filter { $0.storeCount > 0 }
            .map { $0.toMarkerData() }
    }

    private func clusterByRegion(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var seoulClusters = initializeClusters(type: .seoul)
        var gyeonggiClusters = initializeClusters(type: .gyeonggi)
        var metroClusters = initializeClusters(type: .metropolitan)

        for store in stores {
            if let cluster = findClusterForStore(store, in: seoulClusters) {
                cluster.stores.append(store)
                cluster.storeCount += 1
            } else if let cluster = findClusterForStore(store, in: gyeonggiClusters) {
                cluster.stores.append(store)
                cluster.storeCount += 1
            } else if let cluster = findClusterForStore(store, in: metroClusters) {
                cluster.stores.append(store)
                cluster.storeCount += 1
            }
        }

        let allClusters = seoulClusters + gyeonggiClusters + metroClusters
        return allClusters
            .filter { $0.storeCount > 0 }
            .map { $0.toMarkerData() }
    }

    private func clusterByCity(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var clusteredStores = initializeClusters(type: nil)

        for store in stores {
            if let cluster = findClusterForStore(store, in: clusteredStores) {
                cluster.stores.append(store)
                cluster.storeCount += 1
            }
        }

        return clusteredStores
            .filter { $0.storeCount > 0 }
            .map { $0.toMarkerData() }
    }

    private func initializeClusters(type: RegionType?) -> [MutableCluster] {
        if let type = type {
            switch type {
            case .seoul:
                return RegionDefinitions.seoulClusters.map { MutableCluster(base: $0) }
            case .gyeonggi:
                return RegionDefinitions.gyeonggiClusters.map { MutableCluster(base: $0) }
            case .metropolitan:
                return RegionDefinitions.metropolitanClusters.map { MutableCluster(base: $0) }
            case .province:
                return RegionDefinitions.provinceClusters.map { MutableCluster(base: $0) }
            }
        }
        return RegionDefinitions.allClusters.map { MutableCluster(base: $0) }
    }

    private func findClusterForStore(_ store: MapPopUpStore, in clusters: [MutableCluster]) -> MutableCluster? {
        return clusters.first { cluster in
            let address = store.address
            return cluster.base.subRegions.contains { region in
                address.contains(region)
            }
        }
    }
}
