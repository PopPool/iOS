//
//  GetMyProfileResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/10/25.
//

import Foundation

struct GetMyProfileResponse {
    var profileImageUrl: String?
    var nickname: String?
    var email: String?
    var instagramId: String?
    var intro: String?
    var gender: String?
    var age: Int32
    var interestCategoryList: [Category]
}
