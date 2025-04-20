import Foundation

public struct GetMyPageResponse {
    var nickname: String?
    var profileImageUrl: String?
    var intro: String?
    var instagramId: String?
    var loginYn: Bool
    var adminYn: Bool
    var myCommentedPopUpList: [GetMyPagePopUpResponse]
}

public struct GetMyPagePopUpResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var mainImageUrl: String?
}
