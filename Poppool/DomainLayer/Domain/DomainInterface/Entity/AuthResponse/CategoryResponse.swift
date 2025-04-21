import Foundation

public struct CategoryResponse {
    public init(categoryId: Int64, category: String) {
        self.categoryId = categoryId
        self.category = category
    }
    
    public let categoryId: Int64
    public let category: String
}
