//
//  PreSignedURLResponseDTO.swift
//  PopPool
//
//  Created by SeoJunYoung on 9/5/24.
//

import Foundation

struct PreSignedURLResponseDTO: Decodable {
    var preSignedUrlList: [PreSignedURLDTO]
}
