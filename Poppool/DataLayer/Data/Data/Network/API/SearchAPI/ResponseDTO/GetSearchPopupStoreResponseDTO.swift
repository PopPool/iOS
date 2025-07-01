import Foundation

import DomainInterface

struct GetSearchPopupStoreResponseDTO: Decodable {
    var popUpStoreList: [PopUpStoreResponseDTO]
    var loginYn: Bool
}

extension GetSearchPopupStoreResponseDTO {
    func toDomain() -> KeywordBasePopupStoreListResponse {
        return KeywordBasePopupStoreListResponse(
            popupStoreList: popUpStoreList.map { $0.toDomain() },
            loginYn: loginYn
        )
    }
}
