import Foundation

public struct GetNoticeListResponse {
    var noticeInfoList: [GetNoticeListDataResponse]
}

public struct GetNoticeListDataResponse {
    var id: Int64
    var title: String?
    var createdDateTime: String?
}
