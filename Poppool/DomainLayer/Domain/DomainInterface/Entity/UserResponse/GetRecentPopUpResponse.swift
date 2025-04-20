import Foundation

public struct GetRecentPopUpResponse {
    public init(popUpInfoList: [GetRecentPopUpDataResponse], totalPages: Int32, totalElements: Int32) {
        self.popUpInfoList = popUpInfoList
        self.totalPages = totalPages
        self.totalElements = totalElements
    }

    var popUpInfoList: [GetRecentPopUpDataResponse]
    var totalPages: Int32
    var totalElements: Int32
}

public struct GetRecentPopUpDataResponse {
    public init(popUpStoreId: Int64, popUpStoreName: String? = nil, desc: String? = nil, mainImageUrl: String? = nil, startDate: String? = nil, endDate: String? = nil, address: String? = nil, closeYn: Bool) {
        self.popUpStoreId = popUpStoreId
        self.popUpStoreName = popUpStoreName
        self.desc = desc
        self.mainImageUrl = mainImageUrl
        self.startDate = startDate
        self.endDate = endDate
        self.address = address
        self.closeYn = closeYn
    }
    
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closeYn: Bool
}
