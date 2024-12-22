//
//  GetPopUpDetailResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/10/24.
//

import Foundation

struct GetPopUpDetailResponse {
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
    let mainImageUrl: String?
    let imageList: [GetPopUpDetailImageResponse]
    let commentList: [GetPopUpDetailCommentResponse]
    let similarPopUpStoreList: [GetPopUpDetailSimilarResponse]
}

struct GetPopUpDetailImageResponse {
    let id: Int64
    let imageUrl: String?
}

struct GetPopUpDetailCommentResponse {
    let commentId: Int64
    let creator: String?
    let nickname: String?
    let instagramId: String?
    let profileImageUrl: String?
    let content: String?
    let likeYn: Bool
    let likeCount: Int64
    let createDateTime: String?
    let commentImageList: [GetPopUpDetailImageResponse]
}

struct GetPopUpDetailSimilarResponse {
    let id: Int64
    let name: String?
    let mainImageUrl: String?
    let endDate: String?
}
