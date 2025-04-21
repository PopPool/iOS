import Foundation

public struct GetMyPageResponse {
    public init(nickname: String? = nil, profileImageUrl: String? = nil, intro: String? = nil, instagramId: String? = nil, loginYn: Bool, adminYn: Bool, myCommentedPopUpList: [GetMyPagePopUpResponse]) {
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.intro = intro
        self.instagramId = instagramId
        self.loginYn = loginYn
        self.adminYn = adminYn
        self.myCommentedPopUpList = myCommentedPopUpList
    }

    public var nickname: String?
    public var profileImageUrl: String?
    public var intro: String?
    public var instagramId: String?
    public var loginYn: Bool
    public var adminYn: Bool
    public var myCommentedPopUpList: [GetMyPagePopUpResponse]
}

public struct GetMyPagePopUpResponse {
    public init(popUpStoreId: Int64, popUpStoreName: String? = nil, mainImageUrl: String? = nil) {
        self.popUpStoreId = popUpStoreId
        self.popUpStoreName = popUpStoreName
        self.mainImageUrl = mainImageUrl
    }
    
    public var popUpStoreId: Int64
    public var popUpStoreName: String?
    public var mainImageUrl: String?
}
