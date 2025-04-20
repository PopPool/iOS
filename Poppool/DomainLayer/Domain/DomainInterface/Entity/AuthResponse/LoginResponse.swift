import Foundation

public struct LoginResponse {
    public init(userId: String, grantType: String, accessToken: String, refreshToken: String, accessTokenExpiresAt: String, refreshTokenExpiresAt: String, socialType: String, isRegisteredUser: Bool) {
        self.userId = userId
        self.grantType = grantType
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiresAt = accessTokenExpiresAt
        self.refreshTokenExpiresAt = refreshTokenExpiresAt
        self.socialType = socialType
        self.isRegisteredUser = isRegisteredUser
    }

    var userId: String
    var grantType: String
    var accessToken: String
    var refreshToken: String
    var accessTokenExpiresAt: String
    var refreshTokenExpiresAt: String
    var socialType: String
    var isRegisteredUser: Bool
}
