import Foundation

struct EmptyResponse: Decodable {}

struct AdminAPIEndpoint {

    // MARK: - Store List
    static func fetchStoreList(
        query: String?,
        page: Int,
        size: Int
    ) -> Endpoint<GetAdminPopUpStoreListResponseDTO> {
        let params = StoreListRequestDTO(
            query: query,
            page: page,
            size: size
        )
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/admin/popup-stores/list",
            method: .get,
            queryParameters: params
        )
    }

    // MARK: - Store Detail
    static func fetchStoreDetail(
        id: Int64
    ) -> Endpoint<GetAdminPopUpStoreDetailResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/admin/popup-stores",
            method: .get,
            queryParameters: ["popUpStoreId": id]
        )
    }

    // MARK: - Create Store
    static func createStore(
        request: CreatePopUpStoreRequestDTO
    ) -> Endpoint<EmptyResponse> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/admin/popup-stores",
            method: .post,
            bodyParameters: request
        )
    }

    // MARK: - Update Store
    static func updateStore(
        request: UpdatePopUpStoreRequestDTO
    ) -> Endpoint<EmptyResponse> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/admin/popup-stores",
            method: .put,
            bodyParameters: request
        )
    }

    // MARK: - Delete Store
    static func deleteStore(
        id: Int64
    ) -> Endpoint<EmptyResponse> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/admin/popup-stores",
            method: .delete,
            queryParameters: ["popUpStoreId": id]
        )
    }

    // MARK: - Notice
    static func createNotice(
        request: CreateNoticeRequestDTO
    ) -> Endpoint<EmptyResponse> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/admin/notice",
            method: .post,
            bodyParameters: request
        )
    }

    static func updateNotice(
        id: Int64,
        request: UpdateNoticeRequestDTO
    ) -> Endpoint<EmptyResponse> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/admin/notice/\(id)",
            method: .put,
            bodyParameters: request
        )
    }

    static func deleteNotice(
        id: Int64
    ) -> Endpoint<EmptyResponse> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/admin/notice/\(id)",
            method: .delete
        )
    }
}
