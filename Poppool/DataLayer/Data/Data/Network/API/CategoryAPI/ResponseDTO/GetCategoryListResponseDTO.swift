import Foundation

import DomainInterface

// MARK: - GetCategoryListResponseDTO
struct GetCategoryListResponseDTO: Codable {
    let categoryResponseList: [CategoryResponseDTO]
}

// MARK: - InterestResponse
struct CategoryResponseDTO: Codable {
    let categoryId: Int32
    let categoryName: String
}

extension CategoryResponseDTO {
    func toDomain() -> CategoryResponse {
        return CategoryResponse(categoryId: Int(categoryId), category: categoryName)
    }
}
