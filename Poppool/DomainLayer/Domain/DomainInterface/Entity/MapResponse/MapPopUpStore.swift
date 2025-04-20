import Foundation

public struct MapPopUpStore: Equatable {
    public let id: Int64
    public let category: String
    public let name: String
    public let address: String
    public let startDate: String
    public let endDate: String
    public let latitude: Double
    public let longitude: Double
    public let markerId: Int64
    public let markerTitle: String
    public let markerSnippet: String
    public let mainImageUrl: String?
}
