import Foundation

public struct KeywordBasePopupStoreListResponse {
    public init(popupStoreList: [PopUpStoreResponse], loginYn: Bool) {
        self.popupStoreList = popupStoreList
        self.loginYn = loginYn
    }

    public var popupStoreList: [PopUpStoreResponse]
    public var loginYn: Bool
}
