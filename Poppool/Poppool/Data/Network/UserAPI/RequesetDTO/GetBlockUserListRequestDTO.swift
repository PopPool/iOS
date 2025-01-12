//
//  GetBlockUserListRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import Foundation

struct GetBlockUserListRequestDTO: Encodable {
    var page: Int32?
    var size: Int32?
    var sort: String?
}
