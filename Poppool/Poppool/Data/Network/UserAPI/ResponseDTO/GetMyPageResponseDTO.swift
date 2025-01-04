//
//  GetMyPageResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/30/24.
//

import Foundation

struct GetMyPageResponseDTO: Decodable {
    var nickname: String?
    var profileImageUrl: String?
    var intro: String?
    var instagramId: String?
    var loginYn: Bool
    var adminYn: Bool
    var myCommentedPopUpList: [GetMyPagePopUpResponseDTO]
}

extension GetMyPageResponseDTO {
    func toDomain() -> GetMyPageResponse {
        return .init(
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            intro: intro,
            instagramId: instagramId,
            loginYn: loginYn,
            adminYn: adminYn,
            myCommentedPopUpList: myCommentedPopUpList.map { $0.toDomain() }
        )
    }
}

struct GetMyPagePopUpResponseDTO: Decodable {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var mainImageUrl: String?
}

extension GetMyPagePopUpResponseDTO {
    func toDomain() -> GetMyPagePopUpResponse {
        return .init(popUpStoreId: popUpStoreId, popUpStoreName: popUpStoreName, mainImageUrl: mainImageUrl)
    }
}
