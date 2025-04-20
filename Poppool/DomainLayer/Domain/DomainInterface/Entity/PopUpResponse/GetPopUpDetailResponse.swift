import Foundation

public struct GetPopUpDetailResponse {
    public init(name: String?, desc: String?, startDate: String?, endDate: String?, startTime: String?, endTime: String?, address: String?, commentCount: Int64, bookmarkYn: Bool, loginYn: Bool, hasCommented: Bool, mainImageUrl: String?, imageList: [GetPopUpDetailImageResponse], commentList: [GetPopUpDetailCommentResponse], similarPopUpStoreList: [GetPopUpDetailSimilarResponse]) {
        self.name = name
        self.desc = desc
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
        self.address = address
        self.commentCount = commentCount
        self.bookmarkYn = bookmarkYn
        self.loginYn = loginYn
        self.hasCommented = hasCommented
        self.mainImageUrl = mainImageUrl
        self.imageList = imageList
        self.commentList = commentList
        self.similarPopUpStoreList = similarPopUpStoreList
    }

    let name: String?
    let desc: String?
    let startDate: String?
    let endDate: String?
    let startTime: String?
    let endTime: String?
    let address: String?
    let commentCount: Int64
    let bookmarkYn: Bool
    let loginYn: Bool
    let hasCommented: Bool
    let mainImageUrl: String?
    let imageList: [GetPopUpDetailImageResponse]
    let commentList: [GetPopUpDetailCommentResponse]
    let similarPopUpStoreList: [GetPopUpDetailSimilarResponse]
}

public struct GetPopUpDetailImageResponse {
    public init(id: Int64, imageUrl: String?) {
        self.id = id
        self.imageUrl = imageUrl
    }
    
    let id: Int64
    let imageUrl: String?
}

public struct GetPopUpDetailCommentResponse {
    public init(commentId: Int64, creator: String?, nickname: String?, instagramId: String?, profileImageUrl: String?, content: String?, likeYn: Bool, likeCount: Int64, myCommentYn: Bool, createDateTime: String?, commentImageList: [GetPopUpDetailImageResponse]) {
        self.commentId = commentId
        self.creator = creator
        self.nickname = nickname
        self.instagramId = instagramId
        self.profileImageUrl = profileImageUrl
        self.content = content
        self.likeYn = likeYn
        self.likeCount = likeCount
        self.myCommentYn = myCommentYn
        self.createDateTime = createDateTime
        self.commentImageList = commentImageList
    }
    
    let commentId: Int64
    let creator: String?
    let nickname: String?
    let instagramId: String?
    let profileImageUrl: String?
    let content: String?
    let likeYn: Bool
    let likeCount: Int64
    let myCommentYn: Bool
    let createDateTime: String?
    let commentImageList: [GetPopUpDetailImageResponse]
}

public struct GetPopUpDetailSimilarResponse {
    public init(id: Int64, name: String?, mainImageUrl: String?, endDate: String?) {
        self.id = id
        self.name = name
        self.mainImageUrl = mainImageUrl
        self.endDate = endDate
    }
    
    let id: Int64
    let name: String?
    let mainImageUrl: String?
    let endDate: String?
}
