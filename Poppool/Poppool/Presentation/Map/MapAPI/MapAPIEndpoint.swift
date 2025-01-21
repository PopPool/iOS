//
//  MapAPIEndpoint.swift
//  Poppool
//
//  Created by 김기현 on 12/4/24.
//

import Foundation

struct MapAPIEndpoint {

    /// 뷰 바운즈 내에 있는 팝업 스토어 정보를 조회
    /// - Parameters:
    ///   - northEastLat: 북동쪽 위도
    ///   - northEastLon: 북동쪽 경도
    ///   - southWestLat: 남서쪽 위도
    ///   - southWestLon: 남서쪽 경도
    ///   - categories: 카테고리 필터 배열
    /// - Returns: Endpoint<GetViewBoundPopUpStoreListResponse>
    static func locations_fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [String]
    ) -> Endpoint<GetViewBoundPopUpStoreListResponse> {
        let params = BoundQueryDTO(
            northEastLat: northEastLat,
            northEastLon: northEastLon,
            southWestLat: southWestLat,
            southWestLon: southWestLon,
            categories: categories
        )
        //

        return Endpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/locations/popup-stores",
            method: .get,
            queryParameters: params
        )
    }

    /// 지도에서 검색합니다.
    /// - Parameters:
    ///   - query: 검색어
    ///   - categories: 카테고리 필터 배열
    /// - Returns: Endpoint<MapSearchPopUpStore>
    static func locations_searchStores(
        query: String,
        categories: [String]
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
    let categories: [String]
}

struct SearchQueryDTO: Encodable {
    let query: String
    let categories: [String]?
}
