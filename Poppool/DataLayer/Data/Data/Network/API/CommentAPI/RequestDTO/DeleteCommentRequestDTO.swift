//
//  DeleteCommentRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 2/1/25.
//

import Foundation

struct DeleteCommentRequestDTO: Encodable {
    var popUpStoreId: Int64
    var commentId: Int64
}
