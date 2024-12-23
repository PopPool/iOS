//
//  MapUseCase.swift
//  Poppool
//
//  Created by 김기현 on 12/3/24.
//

import Foundation
import RxSwift

protocol MapUseCase {
    func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [String]
    ) -> Observable<[MapPopUpStore]>

    func searchStores(
        query: String,
        categories: [String]
    ) -> Observable<[MapPopUpStore]>
}

class DefaultMapUseCase: MapUseCase {
    private let repository: MapRepository

    init(repository: MapRepository) {
        self.repository = repository
    }

    func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [String]
    ) -> Observable<[MapPopUpStore]> {
        return repository.fetchStoresInBounds(
            northEastLat: northEastLat,
            northEastLon: northEastLon,
            southWestLat: southWestLat,
            southWestLon: southWestLon,
            categories: categories
        )
        .map { $0.map { $0.toDomain() } }
    }

    func searchStores(
        query: String,
        categories: [String]
    ) -> Observable<[MapPopUpStore]> {
        return repository.searchStores(
            query: query,
            categories: categories
        )
        .map { $0.map { $0.toDomain() } }
    }
}
