//
//  UserAPIEndPoint.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/3/24.
//

import Foundation

import RxSwift

struct UserAPIEndPoint {
    
    static func postBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/bookmark-popupstores",
            method: .post,
            queryParameters: request
        )
    }
    
    static func deleteBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/bookmark-popupstores",
            method: .delete,
            queryParameters: request
        )
    }
    
    static func postCommentLike(request: CommentLikeRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/likes",
            method: .post,
            queryParameters: request
        )
    }
    
    static func deleteCommentLike(request: CommentLikeRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/likes",
            method: .delete,
            queryParameters: request
        )
    }
}
