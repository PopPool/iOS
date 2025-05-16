import Foundation

public struct CategoryResponse {
    public init(categoryId: Int, category: String) {
        self.categoryId = categoryId
        self.category = category
    }

    public let categoryId: Int
    public let category: String
}
