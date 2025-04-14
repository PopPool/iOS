import Foundation

import RxSwift

final class MapUseCaseImpl: MapUseCase {

    private let repository: MapRepository

    init(repository: MapRepository) {
        self.repository = repository
    }

    func fetchCategories() -> Observable<[Category]> {
        return repository.fetchCategories()
    }

    func fetchStoresInBounds(
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
            categories: categories  // ← 그대로 넘긴다
        )
        .map { $0.map { $0.toDomain() } }
    }

    func searchStores(
        query: String,
        categories: [Int64]
    ) -> Observable<[MapPopUpStore]> {
        return repository.searchStores(
            query: query,
            categories: categories.map { Int64($0) ?? 0 }
        )
        .map { $0.map { $0.toDomain() } }
    }
    func filterStoresByLocation(_ stores: [MapPopUpStore], selectedRegions: [String]) -> [MapPopUpStore] {
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
