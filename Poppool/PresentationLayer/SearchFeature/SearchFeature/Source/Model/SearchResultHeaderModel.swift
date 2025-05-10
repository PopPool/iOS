import Foundation

public struct SearchResultHeaderModel: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.title == rhs.title) && (lhs.filterText == rhs.filterText)
    }

    public init(title: String? = nil, count: Int? = 0, filterText: String?) {
        self.filterText = filterText
    }

    let title: String? = nil
    let count: Int? = 0
    var filterText: String? = Filter.shared.title
}
