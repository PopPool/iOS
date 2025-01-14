//
//  GetRecentPopUpResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import Foundation

struct GetRecentPopUpResponse {
    var popUpInfoList: [GetRecentPopUpDataResponse]
    var totalPages: Int32
    var totalElements: Int32
}

struct GetRecentPopUpDataResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closeYn: Bool
}
