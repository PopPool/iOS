import Foundation

public struct MapPopUpStore: Equatable {
    public init(id: Int64, category: String, name: String, address: String, startDate: String, endDate: String, latitude: Double, longitude: Double, markerId: Int64, markerTitle: String, markerSnippet: String, mainImageUrl: String?) {
        self.id = id
        self.category = category
        self.name = name
        self.address = address
        self.startDate = startDate
        self.endDate = endDate
        self.latitude = latitude
        self.longitude = longitude
        self.markerId = markerId
        self.markerTitle = markerTitle
        self.markerSnippet = markerSnippet
        self.mainImageUrl = mainImageUrl
    }

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
