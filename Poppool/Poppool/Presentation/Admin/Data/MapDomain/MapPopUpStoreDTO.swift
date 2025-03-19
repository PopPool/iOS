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

    func toDomain() -> MapPopUpStore {
        return MapPopUpStore(
            id: id,
            category: categoryName,
            name: name,
            address: address,
            startDate: startDate,
            endDate: endDate,
            latitude: latitude,
            longitude: longitude,
            markerId: markerId,
            markerTitle: markerTitle,
            markerSnippet: markerSnippet,
            mainImageUrl: mainImageUrl

        )
    }
}

struct GetViewBoundPopUpStoreListResponse: Decodable {
    let popUpStoreList: [MapPopUpStoreDTO]
}

struct MapSearchResponseDTO: Codable {
    let popUpStoreList: [MapPopUpStoreDTO]
    let loginYn: Bool
}
