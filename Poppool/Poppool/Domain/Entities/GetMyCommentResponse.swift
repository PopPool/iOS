//
//  GetMyCommentResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import Foundation

struct GetMyCommentedPopUpResponse {
    var popUpInfoList: [GetMyCommentedPopUpDataResponse]
}


struct GetMyCommentedPopUpDataResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closedYn: Bool
}
