//
//  PutCommentRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 2/4/25.
//

import Foundation

struct PutCommentRequestDTO: Encodable {
    var popUpStoreId: Int64
    var commentId: Int64
    var content: String?
    var imageUrlList: [PutCommentImageDataRequestDTO]?
}

struct PutCommentImageDataRequestDTO: Encodable {
    var imageId: Int64?
    var imageUrl: String?
    var actionType: String?
}
