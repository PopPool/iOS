//
//  GetOtherUserCommentedPopUpListResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import Foundation

struct GetOtherUserCommentedPopUpListResponseDTO: Decodable {
    var popUpInfoList: [GetOtherUserCommentedPopUpResponseDTO]
}

extension GetOtherUserCommentedPopUpListResponseDTO {
    func toDomain() -> GetOtherUserCommentedPopUpListResponse {
        return .init(popUpInfoList: popUpInfoList.map { $0.toDomain() })
    }
}

struct GetOtherUserCommentedPopUpResponseDTO: Decodable {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closedYn: Bool
}

extension GetOtherUserCommentedPopUpResponseDTO {
    func toDomain() -> GetOtherUserCommentedPopUpResponse {
        return .init(
            popUpStoreId: popUpStoreId,
            popUpStoreName: popUpStoreName,
            desc: desc,
            mainImageUrl: mainImageUrl,
            startDate: startDate.toDate().toPPDateString(),
            endDate: endDate.toDate().toPPDateString(),
            address: address,
            closedYn: closedYn
        )
    }
}
