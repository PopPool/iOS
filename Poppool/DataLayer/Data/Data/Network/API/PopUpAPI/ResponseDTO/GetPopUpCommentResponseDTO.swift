import Foundation

import DomainInterface

struct GetPopUpCommentResponseDTO: Decodable {
    let commentList: [GetPopUpDetailCommentResponseDTO]
}

extension GetPopUpCommentResponseDTO {
    func toDomain() -> GetPopUpCommentResponse {
        return .init(commentList: commentList.map { $0.toDomain() })
    }
}
