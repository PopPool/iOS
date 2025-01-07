//
//  GetMyPageResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/30/24.
//

import Foundation

struct GetMyPageResponse {
    var nickname: String?
    var profileImageUrl: String?
    var intro: String?
    var instagramId: String?
    var loginYn: Bool
    var adminYn: Bool
    var myCommentedPopUpList: [GetMyPagePopUpResponse]
}

struct GetMyPagePopUpResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var mainImageUrl: String?
}
