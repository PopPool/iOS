//
//  MapRepository.swift
//  Poppool
//
//  Created by 송영훈 on 4/14/25.
//


import Foundation

import RxSwift

protocol MapRepository {
    func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [Int64]
    ) -> Observable<[MapPopUpStoreDTO]>

    func searchStores(
        query: String,
        categories: [Int64]
    ) -> Observable<[MapPopUpStoreDTO]>

    func fetchCategories() -> Observable<[CategoryResponse]>
}
