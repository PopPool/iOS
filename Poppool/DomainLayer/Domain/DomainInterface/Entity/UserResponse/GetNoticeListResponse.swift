import Foundation

public struct GetNoticeListResponse {
    public init(noticeInfoList: [GetNoticeListDataResponse]) {
        self.noticeInfoList = noticeInfoList
    }

    var noticeInfoList: [GetNoticeListDataResponse]
}

public struct GetNoticeListDataResponse {
    public init(id: Int64, title: String? = nil, createdDateTime: String? = nil) {
        self.id = id
        self.title = title
        self.createdDateTime = createdDateTime
    }
    
    var id: Int64
    var title: String?
    var createdDateTime: String?
}
