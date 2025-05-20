import Foundation

import Infrastructure

import RxSwift

struct SearchAPIEndPoint {

    static func getSearchPopUpList(request: GetSearchPopupStoreRequestDTO) -> Endpoint<GetSearchPopupStoreResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/search/popup-stores",
            method: .get,
            queryParameters: request
        )
    }
}
