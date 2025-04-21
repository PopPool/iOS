//
//  GetPopUpCommentRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import Foundation

struct GetPopUpCommentRequestDTO: Encodable {
    var commentType: String?
    var page: Int32?
    var size: Int32?
    var sort: String?
    var popUpStoreId: Int64
}
