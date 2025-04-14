//
//  GetHomeInfoDataResponseDTO.swift
//  Poppool
//
//  Created by Porori on 11/26/24.
//

import Foundation

struct PopUpStoreResponseDTO: Decodable {
    let id: Int64
    let categoryName: String?
    let name: String?
    let address: String
    let mainImageUrl: String?
    let startDate: String?
    let endDate: String?
    let bookmarkYn: Bool
}

extension PopUpStoreResponseDTO {
    func toDomain() -> PopUpStoreResponse {
        return PopUpStoreResponse(
            id: id,
            category: categoryName,
            name: name,
            address: address,
            mainImageUrl: mainImageUrl,
            startDate: startDate,
            endDate: endDate,
            bookmarkYn: bookmarkYn
        )
    }
}
