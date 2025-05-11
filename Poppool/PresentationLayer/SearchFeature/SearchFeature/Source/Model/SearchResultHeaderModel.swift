import Foundation

public struct SearchResultHeaderModel: Hashable {
    public init(title: String? = nil, count: Int? = 0, filterText: String?) {
        self.title = title
        self.count = count
        self.filterText = filterText
    }

    var title: String? = nil
    var count: Int? = 0
    var filterText: String? = Filter.shared.title
}
