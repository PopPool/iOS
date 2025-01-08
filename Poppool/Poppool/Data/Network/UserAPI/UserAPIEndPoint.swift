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
    
    static func postUserBlock(request: PostUserBlockRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/block",
            method: .post,
            queryParameters: request
        )
    }
    
    static func deleteUserBlock(request: PostUserBlockRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/block",
            method: .delete,
            queryParameters: request
        )
    }
    
    static func getOtherUserCommentList(request: GetOtherUserCommentListRequestDTO) -> Endpoint<GetOtherUserCommentListResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/\(request.commenterId ?? "")/comments",
            method: .get,
            queryParameters: request
        )
    }
    
    static func getMyPage() -> Endpoint<GetMyPageResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/my-page",
            method: .get
        )
    }
    
    static func postLogout() -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/logout",
            method: .post
        )
    }
    
    static func getWithdrawlList() -> Endpoint<GetWithdrawlListResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/withdrawl/surveys",
            method: .get
        )
    }
    
    static func postWithdrawl(request: PostWithdrawlListRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseUrl.rawValue,
            path: "/users/delete",
            method: .post,
            bodyParameters: request
        )
    }
}
