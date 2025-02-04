import Foundation

// MARK: - Store List Response
struct GetAdminPopUpStoreListResponseDTO: Decodable {
    let popUpStoreList: [PopUpStore]
    let totalPages: Int
    let totalElements: Int

    struct PopUpStore: Decodable {
        let id: Int64
        let name: String
        let categoryName: String
        let mainImageUrl: String
        let address: String
        let latitude: Double
        let longitude: Double
        let description: String
    }


}

// MARK: - Store Detail Response
struct GetAdminPopUpStoreDetailResponseDTO: Decodable {
    let id: Int64
    let name: String
    let categoryId: Int64
    let categoryName: String
    let desc: String
    let address: String
    let startDate: String
    let endDate: String
    let createUserId: String
    let createDateTime: String
    let mainImageUrl: String
    let bannerYn: Bool
    let imageList: [Image]
    let latitude: Double
    let longitude: Double
    let markerTitle: String
    let markerSnippet: String

    struct Image: Decodable {
        let id: Int64
        let imageUrl: String
    }
}

// MARK: - Empty Response
struct EmptyResponse: Decodable {}
