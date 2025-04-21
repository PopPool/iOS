import Foundation

public struct GetNoticeListResponse {
    public init(noticeInfoList: [GetNoticeListDataResponse]) {
        self.noticeInfoList = noticeInfoList
    }

    public var noticeInfoList: [GetNoticeListDataResponse]
}

public struct GetNoticeListDataResponse {
    public init(id: Int64, title: String? = nil, createdDateTime: String? = nil) {
        self.id = id
        self.title = title
        self.createdDateTime = createdDateTime
    }

    public var id: Int64
    public var title: String?
    public var createdDateTime: String?
}
