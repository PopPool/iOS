import Foundation

struct MapPopUpStoreDTO: Codable {
    let id: Int64
    let categoryName: String
    let name: String
    let address: String
    let startDate: String
    let endDate: String
    let latitude: Double
    let longitude: Double
    let markerId: Int64
    let markerTitle: String
    let markerSnippet: String
    let mainImageUrl: String?
    let bookmarkYn: Bool?
}

struct GetViewBoundPopUpStoreListResponse: Decodable {
    let popUpStoreList: [MapPopUpStoreDTO]
}

struct MapSearchResponseDTO: Codable {
    let popUpStoreList: [MapPopUpStoreDTO]
    let loginYn: Bool
}
