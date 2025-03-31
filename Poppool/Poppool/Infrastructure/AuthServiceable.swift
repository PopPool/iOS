//
//  AuthService.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 8/22/24.
//

import UIKit

import RxSwift

protocol AuthServiceable: AnyObject {
    /// 사용자 자격 증명을 가져오는 함수
    /// - Returns: Response 형태의 사용자 자격 증명
    func fetchUserCredential() -> Observable<AuthServiceResponse>
}

struct AuthServiceResponse: Encodable {
    var idToken: String?
    var authorizationCode: String?
    var kakaoUserId: Int64?
    var kakaoAccessToken: String?
}

enum AuthError: Error {
    case notInstalled
    case unknownError(description: String?)
}
