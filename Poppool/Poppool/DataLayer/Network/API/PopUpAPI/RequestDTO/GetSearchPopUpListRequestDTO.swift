//
//  GetSearchPopUpListRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/6/24.
//

import Foundation

struct GetSearchPopUpListRequestDTO: Encodable {
    var categories: String?
    var page: Int32?
    var size: Int32?
    var sort: String?
    var query: String?
    var sortCode: String?
}
