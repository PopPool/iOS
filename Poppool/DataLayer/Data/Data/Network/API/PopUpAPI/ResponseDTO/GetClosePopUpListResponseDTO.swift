import Foundation

import DomainInterface

struct GetClosePopUpListResponseDTO: Decodable {
    var closedPopUpStoreList: [PopUpStoreResponseDTO]
    var loginYn: Bool
    var totalPages: Int32
    var totalElements: Int64
}

extension GetClosePopUpListResponseDTO {
    func toDomain() -> GetSearchBottomPopUpListResponse {
        return .init(popUpStoreList: closedPopUpStoreList.map { $0.toDomain() }, loginYn: loginYn, totalPages: totalPages, totalElements: totalElements)
    }
}
