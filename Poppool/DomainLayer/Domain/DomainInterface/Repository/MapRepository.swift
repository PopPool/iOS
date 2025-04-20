import Foundation

import RxSwift

public protocol MapRepository {
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

    func fetchCategories() -> Observable<[CategoryResponse]>
}
