import Foundation

public struct PopUpStoreResponse {
    public init(id: Int64, category: String?, name: String?, address: String?, mainImageUrl: String?, startDate: String?, endDate: String?, bookmarkYn: Bool) {
        self.id = id
        self.category = category
        self.name = name
        self.address = address
        self.mainImageUrl = mainImageUrl
        self.startDate = startDate
        self.endDate = endDate
        self.bookmarkYn = bookmarkYn
    }

    public let id: Int64
    public let category: String?
    public let name: String?
    public let address: String?
    public let mainImageUrl: String?
    public let startDate: String?
    public let endDate: String?
    public let bookmarkYn: Bool
}
