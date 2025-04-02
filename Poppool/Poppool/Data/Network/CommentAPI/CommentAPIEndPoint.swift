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
            baseURL: KeyPath.popPoolBaseURL,
            path: "/comments",
            method: .post,
            bodyParameters: request
        )
    }

    static func deleteComment(request: DeleteCommentRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: KeyPath.popPoolBaseURL,
            path: "/comments",
            method: .delete,
            queryParameters: request
        )
    }

    static func editComment(request: PutCommentRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: KeyPath.popPoolBaseURL,
            path: "/comments",
            method: .put,
            bodyParameters: request
        )
    }
}
