//
//  GetOpenPopUpListResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/6/24.
//

import Foundation

struct GetOpenPopUpListResponseDTO: Decodable {
    var openPopUpStoreList: [PopUpStoreResponseDTO]
    var loginYn: Bool
    var totalPages: Int32
    var totalElements: Int64
}

extension GetOpenPopUpListResponseDTO {
    func toDomain() -> GetSearchBottomPopUpListResponse {
        return .init(popUpStoreList: openPopUpStoreList.map { $0.toDomain() }, loginYn: loginYn, totalPages: totalPages, totalElements: totalElements)
    }
}
