import Foundation

struct HomeAPIEndpoint {

    static func fetchHome(
        request: HomeSortedRequestDTO
    ) -> Endpoint<GetHomeInfoResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/home",
            method: .get,
            queryParameters: request
        )
    }

    static func fetchPopularPopUp(
        request: HomeSortedRequestDTO
    ) -> Endpoint<GetHomeInfoResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/home/popular/popup-stores",
            method: .get,
            queryParameters: request
        )
    }

    static func fetchNewPopUp(
        request: HomeSortedRequestDTO
    ) -> Endpoint<GetHomeInfoResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/home/new/popup-stores",
            method: .get,
            queryParameters: request
        )
    }

    static func fetchCustomPopUp(
        request: HomeSortedRequestDTO
    ) -> Endpoint<GetHomeInfoResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/home/custom/popup-stores",
            method: .get,
            queryParameters: request
        )
    }
}
