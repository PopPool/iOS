//
//  LoginResponse.swift
//  Poppool
//
//  Created by Porori on 11/25/24.
//

import Foundation

struct LoginResponse {
    var userId: String
    var grantType: String
    var accessToken: String
    var refreshToken: String
    var accessTokenExpiresAt: String
    var refreshTokenExpiresAt: String
    var socialType: String
    var isRegisteredUser: Bool
}
