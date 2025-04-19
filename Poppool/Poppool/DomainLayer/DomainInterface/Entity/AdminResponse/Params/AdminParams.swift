import Foundation

struct CreateStoreParams {
    let name: String
    let categoryId: Int64
    let desc: String
    let address: String
    let startDate: String
    let endDate: String
    let mainImageUrl: String
    let imageUrlList: [String?]
    let latitude: Double
    let longitude: Double
    let markerTitle: String
    let markerSnippet: String
    let startDateBeforeEndDate: Bool
}

struct UpdateStoreParams {
    let id: Int64
    let name: String
    let categoryId: Int64
    let desc: String
    let address: String
    let startDate: String
    let endDate: String
    let mainImageUrl: String
    let imageUrlList: [String?]
    let imagesToDelete: [Int64]
    let latitude: Double
    let longitude: Double
    let markerTitle: String
    let markerSnippet: String
    let startDateBeforeEndDate: Bool
}

struct CreateNoticeParams {
    let title: String
    let content: String
    let imageUrlList: [String]
}

struct UpdateNoticeParams {
    let id: Int64
    let title: String
    let content: String
    let imageUrlList: [String]
    let imagesToDelete: [Int64]
}
