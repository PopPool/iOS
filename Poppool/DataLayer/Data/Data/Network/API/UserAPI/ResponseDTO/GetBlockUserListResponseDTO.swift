import Foundation

import DomainInterface

struct GetBlockUserListResponseDTO: Decodable {
    var blockedUserInfoList: [GetBlockUserListDataResponseDTO]
    var totalPages: Int32
    var totalElements: Int32
}

extension GetBlockUserListResponseDTO {
    func toDomain() -> GetBlockUserListResponse {
        return .init(
            blockedUserInfoList: blockedUserInfoList.map { $0.toDomain() },
            totalPages: totalPages,
            totalElements: totalElements
        )
    }
}

struct GetBlockUserListDataResponseDTO: Decodable {
    var userId: String?
    var profileImageUrl: String?
    var nickname: String?
    var instagramId: String?
}

extension GetBlockUserListDataResponseDTO {
    func toDomain() -> GetBlockUserListDataResponse {
        return .init(userId: userId, profileImageUrl: profileImageUrl, nickname: nickname, instagramId: instagramId)
    }
}
