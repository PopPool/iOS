//
//  GetMyCommentedPopUpResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//


import Foundation

struct GetMyCommentedPopUpResponseDTO: Decodable {
    var popUpInfoList: [GetMyCommentedPopUpDataResponseDTO]
}

extension GetMyCommentedPopUpResponseDTO {
    func toDomain() -> GetMyCommentedPopUpResponse {
        return .init(popUpInfoList: popUpInfoList.map { $0.toDomain() })
    }
}

struct GetMyCommentedPopUpDataResponseDTO: Decodable {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closedYn: Bool
}

extension GetMyCommentedPopUpDataResponseDTO {
    func toDomain() -> GetMyCommentedPopUpDataResponse {
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
