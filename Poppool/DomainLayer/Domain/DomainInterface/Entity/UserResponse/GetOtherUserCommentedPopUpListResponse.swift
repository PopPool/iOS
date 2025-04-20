import Foundation

public struct GetOtherUserCommentedPopUpListResponse {
    var popUpInfoList: [GetOtherUserCommentedPopUpResponse]
}

public struct GetOtherUserCommentedPopUpResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closedYn: Bool
}
