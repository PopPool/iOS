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
        Logger.log(
            message: "지도의 범위 내 스토어 정보를 가져옵니다. 카테고리: \(categories)",
            category: .network
        )

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
        .do(
            onNext: { response in
                Logger.log(
                    message: "스토어 조회 성공! 응답: \(response)",
                    category: .network
                )
            },
            onError: { error in
                Logger.log(
                    message: "스토어 조회 중 오류 발생: \(error.localizedDescription)",
                    category: .error
                )
            }
        )
        .map { $0.popUpStoreList }
    }

    func searchStores(
        query: String,
        categories: [String]
    ) -> Observable<[MapPopUpStoreDTO]> {
        Logger.log(
            message: "스토어 검색을 시작합니다. 검색어: '\(query)', 카테고리: \(categories)",
            category: .network
        )

        return provider.requestData(
            with: MapAPIEndpoint.locations_searchStores(
                query: query,
                categories: categories
            ),
            interceptor: nil
        )
        .do(
            onNext: { response in
                Logger.log(
                    message: "스토어 검색 성공! 응답: \(response)",
                    category: .network
                )
            },
            onError: { error in
                Logger.log(
                    message: "스토어 검색 중 오류 발생: \(error.localizedDescription)",
                    category: .error
                )
            }
        )
        .map { $0.popUpStoreList }
    }
}
