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

    public var userId: String
    var grantType: String
    public var accessToken: String
    public var refreshToken: String
    var accessTokenExpiresAt: String
    var refreshTokenExpiresAt: String
    public var socialType: String
    public var isRegisteredUser: Bool
}
