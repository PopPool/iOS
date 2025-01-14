//
//  GetBlockUserListResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import Foundation

struct GetBlockUserListResponse {
    var blockedUserInfoList: [GetBlockUserListDataResponse]
    var totalPages: Int32
    var totalElements: Int32
}

struct GetBlockUserListDataResponse {
    var userId: String?
    var profileImageUrl: String?
    var nickname: String?
    var instagramId: String?
}
