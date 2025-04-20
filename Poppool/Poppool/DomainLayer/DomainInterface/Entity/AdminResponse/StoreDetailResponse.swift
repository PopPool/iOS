import Foundation

struct StoreDetailResponse {
    let id: Int64
    let name: String
    let categoryId: Int64
    let categoryName: String
    let description: String
    let address: String
    let startDate: String
    let endDate: String
    let createUserId: String
    let createDateTime: String
    let mainImageUrl: String
    let bannerYn: Bool
    let images: [StoreImage]
    let latitude: Double
    let longitude: Double
    let markerTitle: String
    let markerSnippet: String

    struct StoreImage {
        let id: Int64
        let imageUrl: String
    }
}
