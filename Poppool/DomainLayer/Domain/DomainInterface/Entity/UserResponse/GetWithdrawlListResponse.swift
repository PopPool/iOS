import Foundation

public struct GetWithdrawlListResponse {
    public init(withDrawlSurveyList: [GetWithdrawlListDataResponse]) {
        self.withDrawlSurveyList = withDrawlSurveyList
    }

    var withDrawlSurveyList: [GetWithdrawlListDataResponse]
}

public struct GetWithdrawlListDataResponse {
    public init(id: Int64, survey: String? = nil) {
        self.id = id
        self.survey = survey
    }
    
    public var id: Int64
    public var survey: String?
}
