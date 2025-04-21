import Foundation

import DomainInterface

struct PostTokenReissueResponseDTO: Decodable {
    var accessToken: String?
    var refreshToken: String?
    var accessTokenExpiresAt: String?
    var refreshTokenExpiresAt: String?
}

extension PostTokenReissueResponseDTO {
    func toDomain() -> PostTokenReissueResponse {
        return .init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            accessTokenExpiresAt: accessTokenExpiresAt,
            refreshTokenExpiresAt: accessTokenExpiresAt
        )
    }
}
