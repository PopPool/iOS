//
//  GetNoticeListResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/13/25.
//

import Foundation

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
