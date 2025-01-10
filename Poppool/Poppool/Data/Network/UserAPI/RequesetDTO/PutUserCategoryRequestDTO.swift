//
//  PutUserCategoryRequestDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/10/25.
//

import Foundation

struct PutUserCategoryRequestDTO: Encodable {
    var interestCategoriesToAdd: [Int64]
    var interestCategoriesToDelete: [Int64]
    var interestCategoriesToKeep: [Int64]
}
