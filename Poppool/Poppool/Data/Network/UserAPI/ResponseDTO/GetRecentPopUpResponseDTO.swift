//
//  GetRecentPopUpResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import Foundation

struct GetRecentPopUpResponseDTO: Decodable {
    var popUpInfoList: [GetRecentPopUpDataResponseDTO]
    var totalPages: Int32
    var totalElements: Int32
}

extension GetRecentPopUpResponseDTO {
    func toDomain() -> GetRecentPopUpResponse {
        return .init(popUpInfoList: popUpInfoList.map { $0.toDomain() }, totalPages: totalPages, totalElements: totalElements)
    }
}

struct GetRecentPopUpDataResponseDTO: Decodable {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closeYn: Bool
}

extension GetRecentPopUpDataResponseDTO {
    func toDomain() -> GetRecentPopUpDataResponse {
        return .init(
            popUpStoreId: popUpStoreId,
            popUpStoreName: popUpStoreName,
            desc: desc, mainImageUrl: mainImageUrl,
            startDate: startDate.toDate().toPPDateString(),
            endDate: endDate.toDate().toPPDateString(),
            address: address,
            closeYn: closeYn
        )
    }
}
