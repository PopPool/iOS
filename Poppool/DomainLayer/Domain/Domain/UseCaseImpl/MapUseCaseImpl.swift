import Foundation

import DomainInterface
import Infrastructure

import RxSwift

public final class MapUseCaseImpl: MapUseCase {

    private let repository: MapRepository

    public init(repository: MapRepository) {
        self.repository = repository
    }

    public func fetchCategories() -> Observable<[CategoryResponse]> {
        return repository.fetchCategories()
    }

    public func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [Int64]
    ) -> Observable<[MapPopUpStore]> {
        return repository.fetchStoresInBounds(
            northEastLat: northEastLat,
            northEastLon: northEastLon,
            southWestLat: southWestLat,
            southWestLon: southWestLon,
            categories: categories
        )
        .do(onNext: { stores in
            Logger.log("맵 범위 내 스토어 \(stores.count)개 로드됨", category: .debug)
        }, onError: { error in
            Logger.log("맵 범위 내 스토어 로드 실패: \(error)", category: .error)
        })
    }

    public func searchStores(
        query: String,
        categories: [Int64]
    ) -> Observable<[MapPopUpStore]> {
        return repository.searchStores(
            query: query,
            categories: categories
        )
        .do(onNext: { stores in
            Logger.log("'\(query)' 검색 결과 \(stores.count)개 로드됨", category: .debug)
        }, onError: { error in
            Logger.log("스토어 검색 실패: \(error)", category: .error)
        })
    }

    public func filterStoresByLocation(_ stores: [MapPopUpStore], selectedRegions: [String]) -> [MapPopUpStore] {
        guard !selectedRegions.isEmpty else { return stores }

        return stores.filter { store in
            let components = store.address.components(separatedBy: " ")
            guard components.count >= 2 else { return false }

            let mainRegion = components[0].replacingOccurrences(of: "특별시", with: "")
                                     .replacingOccurrences(of: "광역시", with: "")
            let subRegion = components[1]

            return selectedRegions.contains("\(mainRegion)전체") ||
                   selectedRegions.contains(subRegion)
        }
    }
}
