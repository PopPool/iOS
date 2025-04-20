import Foundation

public struct AdminStoreDetail {
    public init(id: Int64, name: String, categoryId: Int64, categoryName: String, description: String, address: String, startDate: String, endDate: String, createUserId: String, createDateTime: String, mainImageUrl: String, bannerYn: Bool, images: [StoreImage], latitude: Double, longitude: Double, markerTitle: String, markerSnippet: String) {
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.description = description
        self.address = address
        self.startDate = startDate
        self.endDate = endDate
        self.createUserId = createUserId
        self.createDateTime = createDateTime
        self.mainImageUrl = mainImageUrl
        self.bannerYn = bannerYn
        self.images = images
        self.latitude = latitude
        self.longitude = longitude
        self.markerTitle = markerTitle
        self.markerSnippet = markerSnippet
    }
    
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
        public init(id: Int64, imageUrl: String) {
            self.id = id
            self.imageUrl = imageUrl
        }
        
        public let id: Int64
        public let imageUrl: String
    }
}
