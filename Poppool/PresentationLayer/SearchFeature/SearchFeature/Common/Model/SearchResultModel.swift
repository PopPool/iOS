import Foundation

public struct SearchResultModel: Hashable {
    var imagePath: String?
    var id: Int64
    var category: String?
    var title: String?
    var address: String?
    var startDate: String?
    var endDate: String?
    var isBookmark: Bool
    var isLogin: Bool
    var isPopular: Bool = false
    var row: Int?

    enum EmptyCase {
        case option
        case keyword
    }
}
