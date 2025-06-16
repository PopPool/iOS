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

    public let name: String?
    public let desc: String?
    public let startDate: String?
    public let endDate: String?
    public let startTime: String?
    public let endTime: String?
    public let address: String?
    public let commentCount: Int64
    public let bookmarkYn: Bool
    public let loginYn: Bool
    public let hasCommented: Bool
    public let mainImageUrl: String?
    public let imageList: [GetPopUpDetailImageResponse]
    public let commentList: [GetPopUpDetailCommentResponse]
    public let similarPopUpStoreList: [GetPopUpDetailSimilarResponse]
}

public struct GetPopUpDetailImageResponse {
    public init(id: Int64, imageUrl: String?) {
        self.id = id
        self.imageUrl = imageUrl
    }

    public let id: Int64
    public let imageUrl: String?
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

    public let commentId: Int64
    public let creator: String?
    public let nickname: String?
    public let instagramId: String?
    public let profileImageUrl: String?
    public let content: String?
    public let likeYn: Bool
    public let likeCount: Int64
    public let myCommentYn: Bool
    public let createDateTime: String?
    public let commentImageList: [GetPopUpDetailImageResponse]
}

public struct GetPopUpDetailSimilarResponse {
    public init(id: Int64, name: String?, mainImageUrl: String?, endDate: String?) {
        self.id = id
        self.name = name
        self.mainImageUrl = mainImageUrl
        self.endDate = endDate
    }

    public let id: Int64
    public let name: String?
    public let mainImageUrl: String?
    public let endDate: String?
}
