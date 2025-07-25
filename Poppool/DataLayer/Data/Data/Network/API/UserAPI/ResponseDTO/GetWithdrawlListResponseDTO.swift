import Foundation

import DomainInterface

struct GetWithdrawlListResponseDTO: Decodable {
    var withDrawlSurveyList: [GetWithdrawlListDataResponseDTO]
}
extension GetWithdrawlListResponseDTO {
    func toDomain() -> GetWithdrawlListResponse {
        return .init(withDrawlSurveyList: withDrawlSurveyList.map { $0.toDomain() })
    }
}

struct GetWithdrawlListDataResponseDTO: Codable {
    var id: Int64
    var survey: String?
}
extension GetWithdrawlListDataResponseDTO {
    func toDomain() -> GetWithdrawlListDataResponse {
        return .init(id: id, survey: survey)
    }
}

struct PostWithdrawlListRequestDTO: Encodable {
    var checkedSurveyList: [GetWithdrawlListDataResponseDTO]
}
