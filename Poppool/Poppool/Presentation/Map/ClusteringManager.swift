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
        switch level {
        case .country:
            return clusterByProvince(stores)
        case .city:
            return clusterByCityLevel(stores)
        case .district:
            return clusterByDistrict(stores)
        case .detailed:
            return []
        }
    }

    private func clusterByCityLevel(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        var clusters: [String: MutableCluster] = [:]

        // 미리 클러스터 초기화
        let predefinedClusters = [
            ("서울 북부", RepresentativeScope.seoulNorth.center),
            ("서울 남부", RepresentativeScope.seoulSouth.center),
            ("경기 북부", RepresentativeScope.gyeonggiNorth.center),
            ("경기 남부", RepresentativeScope.gyeonggiSouth.center)
        ]

        // 미리 클러스터 생성
        for (name, coordinate) in predefinedClusters {
            let baseRegion = RegionCluster(
                name: name,
                subRegions: [name],
                coordinate: coordinate,
                type: .metropolitan
            )
            clusters[name] = MutableCluster(base: baseRegion, fixedCenter: coordinate)
        }

        for store in stores {
            let city = extractCity(from: store.address)
            var clusterKey: String

            if city == "서울" {
                clusterKey = seoulNorthRegions.contains(where: { store.address.contains($0) }) ?
                    "서울 북부" : "서울 남부"
            } else if city == "경기" {
                clusterKey = gyeonggiNorthRegions.contains(where: { store.address.contains($0) }) ?
                    "경기 북부" : "경기 남부"
            } else {
                // 다른 도시는 기존 방식 유지
                clusterKey = city
                if clusters[clusterKey] == nil {
                    if let coordinate = getFixedCenterForCity(city) {
                        let baseRegion = RegionCluster(
                            name: clusterKey,
                            subRegions: [clusterKey],
                            coordinate: coordinate,
                            type: .metropolitan
                        )
                        clusters[clusterKey] = MutableCluster(base: baseRegion, fixedCenter: coordinate)
                    }
                }
            }

            if let cluster = clusters[clusterKey] {
                cluster.stores.append(store)
                cluster.storeCount += 1
            }
        }

        return clusters.values
            .filter { $0.storeCount > 0 }
            .map { $0.toMarkerData() }
    }

    private func clusterByDistrict(_ stores: [MapPopUpStore]) -> [ClusterMarkerData] {
        // 1) 서울 구 클러스터 딕셔너리
        var seoulClusters: [String: MutableCluster] = [:]
        for cluster in RegionDefinitions.seoulClusters {
            // 고정 좌표 사용
            seoulClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }

        // 2) 경기 시 클러스터 딕셔너리
        var gyeonggiClusters: [String: MutableCluster] = [:]
        for cluster in RegionDefinitions.gyeonggiClusters {
            // 고정 좌표 사용
            gyeonggiClusters[cluster.name] = MutableCluster(base: cluster, fixedCenter: cluster.coordinate)
        }

        // (선택) 3) 다른 도/광역시도 district 레벨에서 처리하고 싶다면 여기에 추가

        // 4) 스토어 분류
        for store in stores {
            let city = extractCity(from: store.address)

            // 서울 구 찾기
            if city == "서울" {
                // 'seoulClusters' 중 하나와 매칭
                if let clusterName = findMatchingSeoulDistrictName(in: store.address),
                   let cluster = seoulClusters[clusterName] {
                    cluster.stores.append(store)
                    cluster.storeCount += 1
                }
            }
            // 경기 시 찾기
            else if city == "경기" {
                // 'gyeonggiClusters' 중 하나와 매칭
                if let clusterName = findMatchingGyeonggiCityName(in: store.address),
                   let cluster = gyeonggiClusters[clusterName] {
                    cluster.stores.append(store)
                    cluster.storeCount += 1
                }
            }
            else {
                // 그 외는 아직 미구현 or 무시
                Logger.log(message: "🔹 기타 지역(도/광역시) - 주소: \(store.address)", category: .debug)
            }
        }

        // 5) 결과 합쳐서 반환 (서울 + 경기)
        let allClusters = Array(seoulClusters.values) + Array(gyeonggiClusters.values)
        return allClusters
            .filter { $0.storeCount > 0 }
            .map { $0.toMarkerData() }
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

        return clusters.values
            .filter { $0.storeCount > 0 }
            .map { $0.toMarkerData() }
    }

    private func findMatchingSeoulDistrictName(in address: String) -> String? {
        // RegionDefinitions.seoulClusters 중
        // subRegions에 address가 포함된 클러스터.name 반환
        return RegionDefinitions.seoulClusters.first { cluster in
            cluster.subRegions.contains { district in
                address.contains(district)
            }
        }?.name
    }

    private func findMatchingGyeonggiCityName(in address: String) -> String? {
        // RegionDefinitions.gyeonggiClusters 중
        // subRegions에 address가 포함된 클러스터.name 반환
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
