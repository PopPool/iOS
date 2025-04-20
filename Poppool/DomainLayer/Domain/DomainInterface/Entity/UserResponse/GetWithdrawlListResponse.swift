import Foundation

public struct GetWithdrawlListResponse {
    var withDrawlSurveyList: [GetWithdrawlListDataResponse]
}

public struct GetWithdrawlListDataResponse {
    var id: Int64
    var survey: String?
}
