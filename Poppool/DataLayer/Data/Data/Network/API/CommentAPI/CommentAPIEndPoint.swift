import Foundation

import Infrastructure

import RxSwift

struct CommentAPIEndPoint {

    static func postCommentAdd(request: PostCommentRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/comments",
            method: .post,
            bodyParameters: request
        )
    }

    static func deleteComment(request: DeleteCommentRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/comments",
            method: .delete,
            queryParameters: request
        )
    }

    static func editComment(request: PutCommentRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/comments",
            method: .put,
            bodyParameters: request
        )
    }
}
