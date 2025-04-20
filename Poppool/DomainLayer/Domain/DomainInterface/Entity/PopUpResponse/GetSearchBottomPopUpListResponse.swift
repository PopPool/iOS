import Foundation

public struct GetSearchBottomPopUpListResponse {
    public init(popUpStoreList: [PopUpStoreResponse], loginYn: Bool, totalPages: Int32, totalElements: Int64) {
        self.popUpStoreList = popUpStoreList
        self.loginYn = loginYn
        self.totalPages = totalPages
        self.totalElements = totalElements
    }
    
    var popUpStoreList: [PopUpStoreResponse]
    var loginYn: Bool
    var totalPages: Int32
    var totalElements: Int64
}
