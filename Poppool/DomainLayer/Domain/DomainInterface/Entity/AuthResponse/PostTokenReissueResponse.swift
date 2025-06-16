import Foundation

public struct PostTokenReissueResponse {
    public init(accessToken: String? = nil, refreshToken: String? = nil, accessTokenExpiresAt: String? = nil, refreshTokenExpiresAt: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiresAt = accessTokenExpiresAt
        self.refreshTokenExpiresAt = refreshTokenExpiresAt
    }

    public var accessToken: String?
    public var refreshToken: String?
    public var accessTokenExpiresAt: String?
    public var refreshTokenExpiresAt: String?
}
