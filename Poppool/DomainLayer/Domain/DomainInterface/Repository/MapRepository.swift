import Foundation

import RxSwift

public protocol MapRepository {
    func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [Int]
    ) -> Observable<[MapPopUpStore]>

    func searchStores(
        query: String,
        categories: [Int]
    ) -> Observable<[MapPopUpStore]>

    func fetchCategories() -> Observable<[CategoryResponse]>
}
