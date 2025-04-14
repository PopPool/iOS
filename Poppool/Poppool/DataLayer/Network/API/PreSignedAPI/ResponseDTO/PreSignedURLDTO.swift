//
//  PreSignedURLDTO.swift
//  PopPool
//
//  Created by SeoJunYoung on 9/5/24.
//

import Foundation

struct PreSignedURLDTO: Decodable {
    var objectKey: String
    var preSignedUrl: String
}
