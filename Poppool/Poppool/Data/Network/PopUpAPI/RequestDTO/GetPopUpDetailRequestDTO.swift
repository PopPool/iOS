//
//  GetPopUpDetailRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/10/24.
//

import Foundation

struct GetPopUpDetailRequestDTO: Encodable {
    var commentType: String?
    var popUpStoreId: Int64
    var viewCountYn: Bool?
}
