import Foundation

public struct GetSearchPopUpListResponse {
    public init(popUpStoreList: [PopUpStoreResponse], loginYn: Bool) {
        self.popUpStoreList = popUpStoreList
        self.loginYn = loginYn
    }

    public var popUpStoreList: [PopUpStoreResponse]
    public var loginYn: Bool
}
