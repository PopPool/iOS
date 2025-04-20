import Foundation

public struct AdminStoreDetail {
    public let id: Int64
    public let name: String
    public let categoryId: Int64
    public let categoryName: String
    public let description: String
    public let address: String
    public let startDate: String
    public let endDate: String
    public let createUserId: String
    public let createDateTime: String
    public let mainImageUrl: String
    public let bannerYn: Bool
    public let images: [StoreImage]
    public let latitude: Double
    public let longitude: Double
    public let markerTitle: String
    public let markerSnippet: String

    public struct StoreImage {
        public let id: Int64
        public let imageUrl: String
    }
}
