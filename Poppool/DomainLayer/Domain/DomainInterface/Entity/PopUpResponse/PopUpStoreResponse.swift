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

    let id: Int64
    let category: String?
    let name: String?
    let address: String?
    let mainImageUrl: String?
    let startDate: String?
    let endDate: String?
    let bookmarkYn: Bool
}
