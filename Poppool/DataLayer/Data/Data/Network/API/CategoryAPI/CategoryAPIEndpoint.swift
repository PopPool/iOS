import Foundation

import Infrastructure

struct CategoryAPIEndpoint {

    /// 관심사 목록을 가져옵니다.
    /// - Returns: Endpoint<GetInterestListResponseDTO>
    static func getCategoryList() -> Endpoint<GetCategoryListResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/categories",
            method: .get
        )
    }
}
