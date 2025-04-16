//
//  SortedRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/28/24.
//

// TODO: SortedRequestDTO를 HOME, User로 나눠서 폴더에 넣어주기

import Foundation

struct SortedRequestDTO: Encodable {
    var page: Int32?
    var size: Int32?
    var sort: String?
}
