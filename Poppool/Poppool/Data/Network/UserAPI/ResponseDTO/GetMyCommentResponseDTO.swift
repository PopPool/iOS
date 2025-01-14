//
//  GetMyCommentResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//


import Foundation

struct GetMyCommentResponseDTO: Decodable {
    var myCommentList: [GetMyCommentDataResponseDTO]
    var totalPages: Int32
    var totalElements: Int64
}

extension GetMyCommentResponseDTO {
    func toDomain() -> GetMyCommentResponse {
        return .init(commentList: myCommentList.map { $0.toDomain() }, totalPages: totalPages, totalElements: totalElements)
    }
}

struct GetMyCommentDataResponseDTO: Decodable {
    var commentId: Int64
    var content: String?
    var likeCount: Int64
    var createDateTime: String?
    var popUpStoreInfo: GetMyCommentPopUpDataResponseDTO
}

extension GetMyCommentDataResponseDTO {
    func toDomain() -> GetMyCommentDataResponse {
        return .init(
            commentId: commentId,
            content: content,
            likeCount: likeCount,
            createDateTime: createDateTime.toDate().toPPDateString(),
            popUpStoreInfo: popUpStoreInfo.toDomain()
        )
    }
}

struct GetMyCommentPopUpDataResponseDTO: Decodable {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var mainImageUrl: String?
    var closeYn: Bool
}

extension GetMyCommentPopUpDataResponseDTO {
    func toDomain() -> GetMyCommentPopUpDataResponse {
        return .init(
            popUpStoreId: popUpStoreId,
            popUpStoreName: popUpStoreName,
            mainImageUrl: mainImageUrl,
            closeYn: closeYn
        )
    }
}
