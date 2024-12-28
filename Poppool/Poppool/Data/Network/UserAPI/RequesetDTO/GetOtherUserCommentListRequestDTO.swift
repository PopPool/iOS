//
//  GetOtherUserCommentListRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import Foundation

struct GetOtherUserCommentListRequestDTO: Encodable {
    var commenterId: String?
    var commentType: String?
    var page: Int32?
    var size: Int32?
    var sort: String?
}
