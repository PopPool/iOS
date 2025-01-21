//
//  MapAPIEndpoint.swift
//  Poppool
//
//  Created by 김기현 on 12/4/24.
//

import Foundation

struct MapAPIEndpoint {
    /// 뷰 바운즈 내에 있는 팝업 스토어 정보를 조회
    static func locations_fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [Int64]
    ) -> Endpoint<GetViewBoundPopUpStoreListResponse> {
        let params = BoundQueryDTO(
            northEastLat: northEastLat,
            northEastLon: northEastLon,
            southWestLat: southWestLat,
            southWestLon: southWestLon,
            categories: categories
        )

        return Endpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/locations/popup-stores",
            method: .get,
            queryParameters: params
        )
    }

    /// 지도에서 검색합니다.
    static func locations_searchStores(
        query: String,
        categories: [Int64]
    ) -> Endpoint<MapSearchResponseDTO> {
        let params = SearchQueryDTO(
            query: query,
            categories: categories.isEmpty ? nil : categories
        )

        return Endpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/locations/search",
            method: .get,
            queryParameters: params
        )
    }
}

// MARK: - Query DTOs
struct BoundQueryDTO: Encodable {
    let northEastLat: Double
    let northEastLon: Double
    let southWestLat: Double
    let southWestLon: Double
    let categories: [Int64]

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(northEastLat, forKey: .northEastLat)
        try container.encode(northEastLon, forKey: .northEastLon)
        try container.encode(southWestLat, forKey: .southWestLat)
        try container.encode(southWestLon, forKey: .southWestLon)

        // 카테고리를 개별 쿼리 파라미터로 인코딩
        for categoryId in categories {
            try container.encode(categoryId, forKey: .categories)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case northEastLat
        case northEastLon
        case southWestLat
        case southWestLon
        case categories
    }
}


struct SearchQueryDTO: Encodable {
    let query: String
    let categories: [Int64]?
}

