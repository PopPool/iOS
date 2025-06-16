import Foundation

public struct CreateStoreParams {
    public init(name: String, categoryId: Int, desc: String, address: String, startDate: String, endDate: String, mainImageUrl: String, imageUrlList: [String?], latitude: Double, longitude: Double, markerTitle: String, markerSnippet: String, startDateBeforeEndDate: Bool) {
        self.name = name
        self.categoryId = categoryId
        self.desc = desc
        self.address = address
        self.startDate = startDate
        self.endDate = endDate
        self.mainImageUrl = mainImageUrl
        self.imageUrlList = imageUrlList
        self.latitude = latitude
        self.longitude = longitude
        self.markerTitle = markerTitle
        self.markerSnippet = markerSnippet
        self.startDateBeforeEndDate = startDateBeforeEndDate
    }

    public let name: String
    public let categoryId: Int
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
    public init(id: Int64, name: String, categoryId: Int, desc: String, address: String, startDate: String, endDate: String, mainImageUrl: String, imageUrlList: [String?], imagesToDelete: [Int64], latitude: Double, longitude: Double, markerTitle: String, markerSnippet: String, startDateBeforeEndDate: Bool) {
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.desc = desc
        self.address = address
        self.startDate = startDate
        self.endDate = endDate
        self.mainImageUrl = mainImageUrl
        self.imageUrlList = imageUrlList
        self.imagesToDelete = imagesToDelete
        self.latitude = latitude
        self.longitude = longitude
        self.markerTitle = markerTitle
        self.markerSnippet = markerSnippet
        self.startDateBeforeEndDate = startDateBeforeEndDate
    }

    public let id: Int64
    public let name: String
    public let categoryId: Int
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
    public let title: String
    public let content: String
    public let imageUrlList: [String]
}

public struct UpdateNoticeParams {
    public let id: Int64
    public let title: String
    public let content: String
    public let imageUrlList: [String]
    public let imagesToDelete: [Int64]
}
