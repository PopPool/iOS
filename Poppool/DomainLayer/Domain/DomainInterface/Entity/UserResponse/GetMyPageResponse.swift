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

    var nickname: String?
    var profileImageUrl: String?
    var intro: String?
    var instagramId: String?
    var loginYn: Bool
    var adminYn: Bool
    var myCommentedPopUpList: [GetMyPagePopUpResponse]
}

public struct GetMyPagePopUpResponse {
    public init(popUpStoreId: Int64, popUpStoreName: String? = nil, mainImageUrl: String? = nil) {
        self.popUpStoreId = popUpStoreId
        self.popUpStoreName = popUpStoreName
        self.mainImageUrl = mainImageUrl
    }
    
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var mainImageUrl: String?
}
