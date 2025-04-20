import Foundation

import DomainInterface

struct PopUpStoreResponseDTO: Decodable {
    let id: Int64
    let categoryName: String?
    let name: String?
    let address: String
    let mainImageUrl: String?
    let startDate: String?
    let endDate: String?
    let bookmarkYn: Bool
}

extension PopUpStoreResponseDTO {
    func toDomain() -> PopUpStoreResponse {
        return PopUpStoreResponse(
            id: id,
            category: categoryName,
            name: name,
            address: address,
            mainImageUrl: mainImageUrl,
            startDate: startDate,
            endDate: endDate,
            bookmarkYn: bookmarkYn
        )
    }
}
