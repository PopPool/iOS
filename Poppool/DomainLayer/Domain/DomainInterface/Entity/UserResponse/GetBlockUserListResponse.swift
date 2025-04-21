import Foundation

public struct GetBlockUserListResponse {
    public init(blockedUserInfoList: [GetBlockUserListDataResponse], totalPages: Int32, totalElements: Int32) {
        self.blockedUserInfoList = blockedUserInfoList
        self.totalPages = totalPages
        self.totalElements = totalElements
    }

    public var blockedUserInfoList: [GetBlockUserListDataResponse]
    public var totalPages: Int32
    public var totalElements: Int32
}

public struct GetBlockUserListDataResponse {
    public init(userId: String? = nil, profileImageUrl: String? = nil, nickname: String? = nil, instagramId: String? = nil) {
        self.userId = userId
        self.profileImageUrl = profileImageUrl
        self.nickname = nickname
        self.instagramId = instagramId
    }
    
    public var userId: String?
    public var profileImageUrl: String?
    public var nickname: String?
    public var instagramId: String?
}
