import Foundation

public struct CreateStoreParams {
    public let name: String
    public let categoryId: Int64
    public let desc: String
    public let address: String
    public let startDate: String
    public let endDate: String
    public let mainImageUrl: String
    public let imageUrlList: [String?]
    public let latitude: Double
    public let longitude: Double
    public let markerTitle: String
    public let markerSnippet: String
    public let startDateBeforeEndDate: Bool
}

public struct UpdateStoreParams {
    public let id: Int64
    public let name: String
    public let categoryId: Int64
    public let desc: String
    public let address: String
    public let startDate: String
    public let endDate: String
    public let mainImageUrl: String
    public let imageUrlList: [String?]
    public let imagesToDelete: [Int64]
    public let latitude: Double
    public let longitude: Double
    public let markerTitle: String
    public let markerSnippet: String
    public let startDateBeforeEndDate: Bool
}

public struct CreateNoticeParams {
    let title: String
    let content: String
    let imageUrlList: [String]
}

public struct UpdateNoticeParams {
    let id: Int64
    let title: String
    let content: String
    let imageUrlList: [String]
    let imagesToDelete: [Int64]
}
