//
//  GetNoticeListResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/13/25.
//

import Foundation

struct GetNoticeListResponse {
    var noticeInfoList: [GetNoticeListDataResponse]
}

struct GetNoticeListDataResponse {
    var id: Int64
    var title: String?
    var createdDateTime: String?
}
