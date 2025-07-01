//
//  PostCommentRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import Foundation

struct PostCommentRequestDTO: Encodable {
    var popUpStoreId: Int64
    var content: String?
    var commentType: String?
    var imageUrlList: [String?]
}
