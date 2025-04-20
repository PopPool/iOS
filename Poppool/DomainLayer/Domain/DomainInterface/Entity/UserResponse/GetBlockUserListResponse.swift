import Foundation

public struct GetBlockUserListResponse {
    var blockedUserInfoList: [GetBlockUserListDataResponse]
    var totalPages: Int32
    var totalElements: Int32
}

public struct GetBlockUserListDataResponse {
    var userId: String?
    var profileImageUrl: String?
    var nickname: String?
    var instagramId: String?
}
