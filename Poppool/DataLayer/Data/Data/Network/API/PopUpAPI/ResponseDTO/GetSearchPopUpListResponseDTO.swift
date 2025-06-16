import Foundation

import DomainInterface

struct GetSearchPopUpListResponseDTO: Decodable {
    var popUpStoreList: [PopUpStoreResponseDTO]
    var loginYn: Bool
}

extension GetSearchPopUpListResponseDTO {
    func toDomain() -> GetSearchPopUpListResponse {
        return .init(popUpStoreList: popUpStoreList.map { $0.toDomain() }, loginYn: loginYn)
    }
}
