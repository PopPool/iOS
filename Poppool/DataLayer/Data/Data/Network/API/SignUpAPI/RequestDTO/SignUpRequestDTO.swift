//
//  SignUpRequestDTO.swift
//  Poppool
//
//  Created by Porori on 11/25/24.
//

import Foundation

struct SignUpRequestDTO: Encodable {
    var nickname: String
    var gender: String
    var age: Int32
    var socialEmail: String
    var socialType: String
    var interestCategories: [Int]
    var appleAuthorizationCode: String?
}
