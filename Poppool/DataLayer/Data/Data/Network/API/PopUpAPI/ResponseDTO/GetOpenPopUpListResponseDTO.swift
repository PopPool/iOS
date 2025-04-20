import Foundation

import DomainInterface

struct GetOpenPopUpListResponseDTO: Decodable {
    var openPopUpStoreList: [PopUpStoreResponseDTO]
    var loginYn: Bool
    var totalPages: Int32
    var totalElements: Int64
}

extension GetOpenPopUpListResponseDTO {
    func toDomain() -> GetSearchBottomPopUpListResponse {
        return .init(popUpStoreList: openPopUpStoreList.map { $0.toDomain() }, loginYn: loginYn, totalPages: totalPages, totalElements: totalElements)
    }
}
