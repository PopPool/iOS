//
//  GetWithdrawlListResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/7/25.
//

import Foundation

struct GetWithdrawlListResponse {
    var withDrawlSurveyList: [GetWithdrawlListDataResponse]
}

struct GetWithdrawlListDataResponse {
    var id: Int64
    var survey: String?
}
