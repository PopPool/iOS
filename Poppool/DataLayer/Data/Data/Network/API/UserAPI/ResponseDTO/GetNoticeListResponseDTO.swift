import Foundation

import DomainInterface

struct GetNoticeListResponseDTO: Decodable {
    var noticeInfoList: [GetNoticeListDataResponseDTO]
}

extension GetNoticeListResponseDTO {
    func toDomain() -> GetNoticeListResponse {
        return .init(noticeInfoList: noticeInfoList.map { $0.toDomain() })
    }
}

struct GetNoticeListDataResponseDTO: Decodable {
    var id: Int64
    var title: String?
    var createdDateTime: String?
}

extension GetNoticeListDataResponseDTO {
    func toDomain() -> GetNoticeListDataResponse {
        return .init(id: id, title: title, createdDateTime: createdDateTime.toDate().toPPDateString())
    }
}
