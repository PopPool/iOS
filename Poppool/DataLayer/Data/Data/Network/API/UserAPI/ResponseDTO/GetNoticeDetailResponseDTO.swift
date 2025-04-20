import Foundation

import DomainInterface

struct GetNoticeDetailResponseDTO: Decodable {
    var id: Int64
    var title: String?
    var content: String?
    var createDateTime: String?
}

extension GetNoticeDetailResponseDTO {
    func toDomain() -> GetNoticeDetailResponse {
        return .init(id: id, title: title, content: content, createDateTime: createDateTime.toDate().toPPDateString())
    }
}
