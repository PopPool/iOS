//
//  UserUnblockRequestDTO.swift
//  PopPool
//
//  Created by SeoJunYoung on 7/23/24.
//

import Foundation

struct UserUnblockRequestDTO: Encodable {
    var userId: String
    var blockedUserId: String
}
