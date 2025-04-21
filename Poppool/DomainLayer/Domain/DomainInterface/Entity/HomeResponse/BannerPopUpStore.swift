import Foundation

public struct BannerPopUpStore {
    public init(id: Int64, name: String, mainImageUrl: String) {
        self.id = id
        self.name = name
        self.mainImageUrl = mainImageUrl
    }

    public var id: Int64
    public var name: String
    public var mainImageUrl: String
}
