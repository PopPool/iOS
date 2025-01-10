//
//  GetMyProfileResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/10/25.
//

import Foundation

struct GetMyProfileResponseDTO: Decodable {
    var profileImageUrl: String?
    var nickname: String?
    var email: String?
    var instagramId: String?
    var intro: String?
    var gender: String?
    var age: Int32
    var interestCategoryList: [CategoryResponseDTO]
}

extension GetMyProfileResponseDTO {
    func toDomain() -> GetMyProfileResponse {
        return .init(profileImageUrl: profileImageUrl, nickname: nickname, email: email, instagramId: instagramId, intro: intro, gender: gender, age: age, interestCategoryList: interestCategoryList.map { $0.toDomain() })
    }
}
