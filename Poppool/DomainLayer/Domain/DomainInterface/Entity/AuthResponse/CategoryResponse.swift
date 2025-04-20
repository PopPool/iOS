import Foundation

public struct CategoryResponse {
    public init(categoryId: Int64, category: String) {
        self.categoryId = categoryId
        self.category = category
    }
    
    let categoryId: Int64
    let category: String
}
