//
//  GetOtherUserCommentListResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import Foundation

struct GetOtherUserCommentListResponse {
    var commentList: [GetOtherUserCommentResponse]
    var totalPages: Int32
    var totalElements: Int64
}

struct GetOtherUserCommentResponse {
    var commentId: Int64
    var content: String?
    var likeCount: Int64
    var createDateTime: String?
    var popUpStoreInfo: GetOtherUserCommentPopUpResponse
}

struct GetOtherUserCommentPopUpResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var mainImageUrl: String?
    var closeYn: Bool
}
