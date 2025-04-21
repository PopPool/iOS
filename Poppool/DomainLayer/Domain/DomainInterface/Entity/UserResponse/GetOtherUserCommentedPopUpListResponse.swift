import Foundation

public struct GetOtherUserCommentedPopUpListResponse {
    public init(popUpInfoList: [GetOtherUserCommentedPopUpResponse]) {
        self.popUpInfoList = popUpInfoList
    }

    public var popUpInfoList: [GetOtherUserCommentedPopUpResponse]
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
    
    public var popUpStoreId: Int64
    public var popUpStoreName: String?
    public var desc: String?
    public var mainImageUrl: String?
    public var startDate: String?
    public var endDate: String?
    public var address: String?
    public var closedYn: Bool
}
