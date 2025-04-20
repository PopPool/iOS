import Foundation

public struct GetBlockUserListResponse {
    public init(blockedUserInfoList: [GetBlockUserListDataResponse], totalPages: Int32, totalElements: Int32) {
        self.blockedUserInfoList = blockedUserInfoList
        self.totalPages = totalPages
        self.totalElements = totalElements
    }

    var blockedUserInfoList: [GetBlockUserListDataResponse]
    var totalPages: Int32
    var totalElements: Int32
}

public struct GetBlockUserListDataResponse {
    public init(userId: String? = nil, profileImageUrl: String? = nil, nickname: String? = nil, instagramId: String? = nil) {
        self.userId = userId
        self.profileImageUrl = profileImageUrl
        self.nickname = nickname
        self.instagramId = instagramId
    }
    
    var userId: String?
    var profileImageUrl: String?
    var nickname: String?
    var instagramId: String?
}
