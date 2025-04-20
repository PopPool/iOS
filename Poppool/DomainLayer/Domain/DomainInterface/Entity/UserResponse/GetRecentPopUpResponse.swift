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

public extension GetRecentPopUpDataResponse {
    func toStoreItem() -> StoreItem {
        return StoreItem(
            id: self.popUpStoreId,
            thumbnailURL: self.mainImageUrl ?? "",
            category: "카테고리",
            title: self.popUpStoreName ?? "제목 없음",
            location: self.address ?? "주소 없음",
            dateRange: "\(self.startDate ?? "") ~ \(self.endDate ?? "")",
            isBookmarked: self.closeYn
        )
    }
}
