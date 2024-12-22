//
//  GetPopUpDetailResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/10/24.
//

import Foundation
// MARK: - Main Model
struct GetPopUpDetailResponseDTO: Decodable {
    let name: String?
    let desc: String?
    let startDate: String?
    let endDate: String?
    let address: String?
    let commentCount: Int64
    let bookmarkYn: Bool
    let loginYn: Bool
    let mainImageUrl: String?
    let imageList: [GetPopUpDetailImageResponseDTO]
    let commentList: [GetPopUpDetailCommentResponseDTO]
    let similarPopUpStoreList: [GetPopUpDetailSimilarResponseDTO]
}

extension GetPopUpDetailResponseDTO {
    func toDomain() -> GetPopUpDetailResponse {
        return .init(
            name: name,
            desc: desc,
            startDate: startDate.toDate().toPPDateString(),
            endDate: endDate.toDate().toPPDateString(),
            startTime: startDate.toDate().toPPTimeeString(),
            endTime: startDate.toDate().toPPTimeeString(),
            address: address,
            commentCount: commentCount,
            bookmarkYn: bookmarkYn,
            loginYn: loginYn,
            mainImageUrl: mainImageUrl,
            imageList: imageList.map { $0.toDomain()},
            commentList: commentList.map { $0.toDomain() },
            similarPopUpStoreList: similarPopUpStoreList.map { $0.toDomain() }
        )
    }
}

struct GetPopUpDetailImageResponseDTO: Decodable {
    let id: Int64
    let imageUrl: String?
}

extension GetPopUpDetailImageResponseDTO {
    func toDomain() -> GetPopUpDetailImageResponse {
        return .init(id: id, imageUrl: imageUrl)
    }
}

struct GetPopUpDetailCommentResponseDTO: Decodable {
    let commentId: Int64
    let creator: String?
    let nickname: String?
    let instagramId: String?
    let profileImageUrl: String?
    let content: String?
    let likeYn: Bool
    let likeCount: Int64
    let createDateTime: String?
    let commentImageList: [GetPopUpDetailImageResponseDTO]?
}

extension GetPopUpDetailCommentResponseDTO {
    func toDomain() -> GetPopUpDetailCommentResponse {
        return .init(
            commentId: commentId,
            creator: creator,
            nickname: nickname,
            instagramId: instagramId,
            profileImageUrl: profileImageUrl,
            content: content,
            likeYn: likeYn,
            likeCount: likeCount,
            createDateTime: createDateTime.toDate().toPPDateString(),
            commentImageList: commentImageList == nil ? [] : commentImageList!.map { $0.toDomain()}
        )
    }
}

struct GetPopUpDetailSimilarResponseDTO: Decodable {
    let id: Int64
    let name: String?
    let mainImageUrl: String?
    let endDate: String?
}

extension GetPopUpDetailSimilarResponseDTO {
    func toDomain() -> GetPopUpDetailSimilarResponse {
        return .init(id: id, name: name, mainImageUrl: mainImageUrl, endDate: endDate.toDate().toPPDateString())
    }
}
