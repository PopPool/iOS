//
//  GetMyCommentResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import Foundation

struct GetMyCommentResponse {
    var commentList: [GetMyCommentDataResponse]
    var totalPages: Int32
    var totalElements: Int64
}

struct GetMyCommentDataResponse {
    var commentId: Int64
    var content: String?
    var likeCount: Int64
    var createDateTime: String?
    var popUpStoreInfo: GetMyCommentPopUpDataResponse
}

struct GetMyCommentPopUpDataResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var mainImageUrl: String?
    var closeYn: Bool
}
