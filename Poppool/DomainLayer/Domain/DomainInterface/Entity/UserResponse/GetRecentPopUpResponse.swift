import Foundation

public struct GetRecentPopUpResponse {
    public init(popUpInfoList: [GetRecentPopUpDataResponse], totalPages: Int32, totalElements: Int32) {
        self.popUpInfoList = popUpInfoList
        self.totalPages = totalPages
        self.totalElements = totalElements
    }

    public var popUpInfoList: [GetRecentPopUpDataResponse]
    public var totalPages: Int32
    public var totalElements: Int32
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

    public var popUpStoreId: Int64
    public var popUpStoreName: String?
    public var desc: String?
    public var mainImageUrl: String?
    public var startDate: String?
    public var endDate: String?
    public var address: String?
    public var closeYn: Bool
}
