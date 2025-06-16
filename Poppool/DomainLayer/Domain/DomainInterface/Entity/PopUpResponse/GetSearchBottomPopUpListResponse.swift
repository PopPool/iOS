import Foundation

public struct GetSearchBottomPopUpListResponse {
    public init(popUpStoreList: [PopUpStoreResponse], loginYn: Bool, totalPages: Int32, totalElements: Int64) {
        self.popUpStoreList = popUpStoreList
        self.loginYn = loginYn
        self.totalPages = totalPages
        self.totalElements = totalElements
    }

    public var popUpStoreList: [PopUpStoreResponse]
    public var loginYn: Bool
    public var totalPages: Int32
    public var totalElements: Int64
}
