import Foundation

public struct GetWithdrawlListResponse {
    var withDrawlSurveyList: [GetWithdrawlListDataResponse]
}

public struct GetWithdrawlListDataResponse {
    public var id: Int64
    public var survey: String?
}
