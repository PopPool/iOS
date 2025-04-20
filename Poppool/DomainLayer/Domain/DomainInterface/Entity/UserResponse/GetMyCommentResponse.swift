import Foundation

public struct GetMyCommentedPopUpResponse {
    var popUpInfoList: [GetMyCommentedPopUpDataResponse]
}

public struct GetMyCommentedPopUpDataResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closedYn: Bool
}
