//
//  GetOtherUserCommentedPopUpListResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import Foundation

struct GetOtherUserCommentedPopUpListResponse {
    var popUpInfoList: [GetOtherUserCommentedPopUpResponse]
}

struct GetOtherUserCommentedPopUpResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closedYn: Bool
}
