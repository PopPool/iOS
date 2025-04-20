//
//  GetCategoryListResponseDTO.swift
//  Poppool
//
//  Created by Porori on 11/25/24.
//

import Foundation

// MARK: - GetCategoryListResponseDTO
struct GetCategoryListResponseDTO: Codable {
    let categoryResponseList: [CategoryResponseDTO]
}

// MARK: - InterestResponse
struct CategoryResponseDTO: Codable {
    let categoryId: Int64
    let categoryName: String
}

extension CategoryResponseDTO {
    func toDomain() -> CategoryResponse {
        return CategoryResponse(categoryId: categoryId, category: categoryName)
    }
}
