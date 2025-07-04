import Foundation

import Infrastructure

import Alamofire

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
            baseURL: Secrets.popPoolBaseURL,
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
            baseURL: Secrets.popPoolBaseURL,
            path: "/locations/search",
            method: .get,
            queryParameters: params
        )
    }
}

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

        let categoriesString = categories.map(String.init).joined(separator: ",")
        try container.encode(categoriesString, forKey: .categories)
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
