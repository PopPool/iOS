import Foundation

public struct AuthServiceResponse: Encodable {
    public init(idToken: String? = nil, authorizationCode: String? = nil, kakaoUserId: Int64? = nil, kakaoAccessToken: String? = nil) {
        self.idToken = idToken
        self.authorizationCode = authorizationCode
        self.kakaoUserId = kakaoUserId
        self.kakaoAccessToken = kakaoAccessToken
    }

    public var idToken: String?
    public var authorizationCode: String?
    public var kakaoUserId: Int64?
    public var kakaoAccessToken: String?
}
