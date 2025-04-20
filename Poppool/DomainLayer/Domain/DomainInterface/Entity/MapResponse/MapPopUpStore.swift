import Foundation

public struct MapPopUpStore: Equatable {
    let id: Int64
    let category: String
    let name: String
    let address: String
    let startDate: String
    let endDate: String
    let latitude: Double
    let longitude: Double
    let markerId: Int64
    let markerTitle: String
    let markerSnippet: String
    let mainImageUrl: String?
}
