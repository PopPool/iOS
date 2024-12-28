//
//  GetPopUpCommentResponseDTO.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import Foundation

struct GetPopUpCommentResponseDTO: Decodable {
    let commentList: [GetPopUpDetailCommentResponseDTO]
}

extension GetPopUpCommentResponseDTO {
    func toDomain() -> GetPopUpCommentResponse {
        return .init(commentList: commentList.map { $0.toDomain() })
    }
}
