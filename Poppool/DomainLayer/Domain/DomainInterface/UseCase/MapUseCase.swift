import Foundation

import RxSwift

public protocol MapUseCase {
    func fetchCategories() -> Observable<[CategoryResponse]>
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

    func filterStoresByLocation(_ stores: [MapPopUpStore], selectedRegions: [String]) -> [MapPopUpStore]
}
