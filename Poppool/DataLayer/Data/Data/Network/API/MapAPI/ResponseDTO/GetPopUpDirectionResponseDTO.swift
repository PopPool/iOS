import Foundation

import DomainInterface

struct GetPopUpDirectionResponseDTO: Decodable {
    let id: Int64
    let categoryName: String
    let name: String
    let address: String
    let startDate: String
    let endDate: String
    let latitude: Double
    let longitude: Double
    let markerId: Int64
    let markerTitle: String
    let markerSnippet: String

    func toDomain() -> GetPopUpDirectionResponse {
        return .init(
            id: id,
            categoryName: categoryName,
            name: name,
            address: address,
            startDate: startDate,
            endDate: endDate,
            latitude: latitude,
            longitude: longitude,
            markerId: markerId,
            markerTitle: markerTitle,
            markerSnippet: markerSnippet
        )
    }
}
