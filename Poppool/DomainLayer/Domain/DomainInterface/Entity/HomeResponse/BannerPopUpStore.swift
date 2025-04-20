import Foundation

public struct BannerPopUpStore {
    public init(id: Int64, name: String, mainImageUrl: String) {
        self.id = id
        self.name = name
        self.mainImageUrl = mainImageUrl
    }

    var id: Int64
    var name: String
    var mainImageUrl: String
}
