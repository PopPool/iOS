//
//  GetRecentPopUpResponse.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import Foundation

struct GetRecentPopUpResponse {
    var popUpInfoList: [GetRecentPopUpDataResponse]
    var totalPages: Int32
    var totalElements: Int32
}

struct GetRecentPopUpDataResponse {
    var popUpStoreId: Int64
    var popUpStoreName: String?
    var desc: String?
    var mainImageUrl: String?
    var startDate: String?
    var endDate: String?
    var address: String?
    var closeYn: Bool
}
extension GetRecentPopUpDataResponse {
    func toStoreItem() -> StoreItem {
        return StoreItem(
            id: Int(self.popUpStoreId), // Int로 변환
            thumbnailURL: self.mainImageUrl ?? "", // URL이 없으면 빈 문자열
            category: "카테고리", // 서버 응답에 category가 없으면 기본값
            title: self.popUpStoreName ?? "제목 없음", // Optional 처리
            location: self.address ?? "주소 없음", // Optional 처리
            dateRange: "\(self.startDate ?? "") ~ \(self.endDate ?? "")", // Optional 처리
            isBookmarked: self.closeYn // Boolean 값
        )
    }

}
