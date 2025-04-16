//
//  MapUseCase.swift
//  Poppool
//
//  Created by 송영훈 on 4/14/25.
//


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
