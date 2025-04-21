import Foundation

public struct GetNoticeDetailResponse {
    public init(id: Int64, title: String? = nil, content: String? = nil, createDateTime: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.createDateTime = createDateTime
    }

    var id: Int64
    public var title: String?
    public var content: String?
    public var createDateTime: String?
}
