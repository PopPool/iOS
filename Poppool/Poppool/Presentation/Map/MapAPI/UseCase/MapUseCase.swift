import Foundation
import RxSwift

protocol MapUseCase {
    func fetchCategories() -> Observable<[Category]>
    func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [Int64]
    ) -> Observable<[MapPopUpStore]>

    func searchStores(
        query: String,
        categories: [Int64]
    ) -> Observable<[MapPopUpStore]>
}
class DefaultMapUseCase: MapUseCase {
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
}
