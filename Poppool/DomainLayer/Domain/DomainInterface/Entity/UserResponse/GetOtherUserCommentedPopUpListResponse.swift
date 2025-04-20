import Foundation

public struct GetOtherUserCommentedPopUpListResponse {
    public init(popUpInfoList: [GetOtherUserCommentedPopUpResponse]) {
        self.popUpInfoList = popUpInfoList
    }

    var popUpInfoList: [GetOtherUserCommentedPopUpResponse]
}

public struct GetOtherUserCommentedPopUpResponse {
    public init(popUpStoreId: Int64, popUpStoreName: String? = nil, desc: String? = nil, mainImageUrl: String? = nil, startDate: String? = nil, endDate: String? = nil, address: String? = nil, closedYn: Bool) {
        self.popUpStoreId = popUpStoreId
        self.popUpStoreName = popUpStoreName
        self.desc = desc
        self.mainImageUrl = mainImageUrl
        self.startDate = startDate
        self.endDate = endDate
        self.address = address
        self.closedYn = closedYn
    }
    
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closedYn: Bool
}
