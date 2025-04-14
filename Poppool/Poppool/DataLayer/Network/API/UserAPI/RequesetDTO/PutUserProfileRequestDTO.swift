//
//  PutUserProfileRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/11/25.
//

import Foundation

struct PutUserProfileRequestDTO: Encodable {
    var profileImageUrl: String?
    var nickname: String?
    var email: String?
    var instagramId: String?
    var intro: String?
}
