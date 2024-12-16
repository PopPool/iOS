//
//  CommentAPIEndPoint.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import Foundation

import RxSwift

struct CommentAPIEndPoint {
    
    static func postCommentAdd(request: PostCommentRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/comments",
            method: .post,
            bodyParameters: request
        )
    }
}
