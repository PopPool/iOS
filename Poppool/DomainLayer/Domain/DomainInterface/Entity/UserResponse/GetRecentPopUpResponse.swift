import Foundation

public struct GetRecentPopUpResponse {
    var popUpInfoList: [GetRecentPopUpDataResponse]
    var totalPages: Int32
    var totalElements: Int32
}

public struct GetRecentPopUpDataResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closeYn: Bool
}
