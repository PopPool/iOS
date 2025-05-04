import Foundation

public struct CategoryResponse {
    public init(categoryId: Int32, category: String) {
        self.categoryId = Int(categoryId)
        self.category = category
    }

    public let categoryId: Int
    public let category: String
}
