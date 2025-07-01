import Foundation

public struct AdminStore {
    public init(id: Int64, name: String, categoryName: String, mainImageUrl: String) {
        self.id = id
        self.name = name
        self.categoryName = categoryName
        self.mainImageUrl = mainImageUrl
    }

    public let id: Int64
    public let name: String
    public let categoryName: String
    public let mainImageUrl: String
}
