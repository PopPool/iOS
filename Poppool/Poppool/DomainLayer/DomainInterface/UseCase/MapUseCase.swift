import Foundation

import RxSwift

protocol MapUseCase {
    func fetchCategories() -> Observable<[CategoryResponse]>
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

    func filterStoresByLocation(_ stores: [MapPopUpStore], selectedRegions: [String]) -> [MapPopUpStore]
}
