//
//  MapRepository.swift
//  Poppool
//
//  Created by 김기현 on 12/3/24.
//

import Foundation
import RxSwift

protocol MapRepository {
    func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [String]
    ) -> Observable<[MapPopUpStoreDTO]>

    func searchStores(
        query: String,
        categories: [String]
    ) -> Observable<[MapPopUpStoreDTO]>
}

class DefaultMapRepository: MapRepository {
    private let provider: Provider

    init(provider: Provider) {
        self.provider = provider
    }

    func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [String]
    ) -> Observable<[MapPopUpStoreDTO]> {
        return provider.requestData(
            with: MapAPIEndpoint.locations_fetchStoresInBounds(
                northEastLat: northEastLat,
                northEastLon: northEastLon,
                southWestLat: southWestLat,
                southWestLon: southWestLon,
                categories: categories
            ),
            interceptor: nil
        )
        .map { $0.popUpStoreList }
    }

    func searchStores(
        query: String,
        categories: [String]
    ) -> Observable<[MapPopUpStoreDTO]> {
        return provider.requestData(
            with: MapAPIEndpoint.locations_searchStores(
                query: query,
                categories: categories
            ),
            interceptor: nil
        )
        .map { $0.popUpStoreList }
    }
}
