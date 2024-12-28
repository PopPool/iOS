//
//  GetOtherUserCommentListResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import Foundation

struct GetOtherUserCommentListResponseDTO: Decodable {
    var commentList: [GetOtherUserCommentResponseDTO]
    var totalPages: Int32
    var totalElements: Int64
}

extension GetOtherUserCommentListResponseDTO {
    func toDomain() -> GetOtherUserCommentListResponse {
        return .init(commentList: commentList.map { $0.toDomain() }, totalPages: totalPages, totalElements: totalElements)
    }
}

struct GetOtherUserCommentResponseDTO: Decodable {
    var commentId: Int64
    var content: String?
    var likeCount: Int64
    var createDateTime: String?
    var popUpStoreInfo: GetOtherUserCommentPopUpResponseDTO
}

extension GetOtherUserCommentResponseDTO {
    func toDomain() -> GetOtherUserCommentResponse {
        return .init(
            commentId: commentId,
            content: content,
            likeCount: likeCount,
            createDateTime: createDateTime.toDate().toPPDateString(),
            popUpStoreInfo: popUpStoreInfo.toDomain()
        )
    }
}

struct GetOtherUserCommentPopUpResponseDTO: Decodable {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var mainImageUrl: String?
    var closeYn: Bool
}

extension GetOtherUserCommentPopUpResponseDTO {
    func toDomain() -> GetOtherUserCommentPopUpResponse {
        return .init(
            popUpStoreId: popUpStoreId,
            popUpStoreName: popUpStoreName,
            mainImageUrl: mainImageUrl,
            closeYn: closeYn
        )
    }
}



