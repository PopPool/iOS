//
//  BannerPopUpStoreDTO.swift
//  Poppool
//
//  Created by Porori on 11/26/24.
//

import Foundation

struct BannerPopUpStoreDTO: Decodable {
    var id: Int64
    var name: String
    var mainImageUrl: String
}

extension BannerPopUpStoreDTO {
    func toDomain() -> BannerPopUpStore {
        .init(
            id: id,
            name: name,
            mainImageUrl: mainImageUrl
        )
    }
}
