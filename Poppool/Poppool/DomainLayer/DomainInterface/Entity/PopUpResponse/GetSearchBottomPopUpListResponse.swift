//
//  GetSearchBottomPopUpListResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/6/24.
//

import Foundation

struct GetSearchBottomPopUpListResponse {
    var popUpStoreList: [PopUpStoreResponse]
    var loginYn: Bool
    var totalPages: Int32
    var totalElements: Int64
}
