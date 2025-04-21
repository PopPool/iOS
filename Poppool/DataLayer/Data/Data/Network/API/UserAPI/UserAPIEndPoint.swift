import Foundation

import Infrastructure

import RxSwift

struct UserAPIEndPoint {

    static func postBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/bookmark-popupstores",
            method: .post,
            queryParameters: request
        )
    }

    static func deleteBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/bookmark-popupstores",
            method: .delete,
            queryParameters: request
        )
    }

    static func postCommentLike(request: CommentLikeRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/likes",
            method: .post,
            queryParameters: request
        )
    }

    static func deleteCommentLike(request: CommentLikeRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/likes",
            method: .delete,
            queryParameters: request
        )
    }

    static func postUserBlock(request: PostUserBlockRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/block",
            method: .post,
            queryParameters: request
        )
    }

    static func deleteUserBlock(request: PostUserBlockRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/unblock",
            method: .delete,
            queryParameters: request
        )
    }

    static func getOtherUserCommentPopUpList(request: GetOtherUserCommentListRequestDTO) -> Endpoint<GetOtherUserCommentedPopUpListResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/\(request.commenterId ?? "")/comments",
            method: .get,
            queryParameters: request
        )
    }

    static func getMyPage() -> Endpoint<GetMyPageResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/my-page",
            method: .get
        )
    }

    static func postLogout() -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/logout",
            method: .post
        )
    }

    static func getWithdrawlList() -> Endpoint<GetWithdrawlListResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/withdrawl/surveys",
            method: .get
        )
    }

    static func postWithdrawl(request: PostWithdrawlListRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/delete",
            method: .post,
            bodyParameters: request
        )
    }

    static func getMyProfile() -> Endpoint<GetMyProfileResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/profiles",
            method: .get
        )
    }

    static func putUserTailoredInfo(request: PutUserTailoredInfoRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/tailored-info",
            method: .put,
            bodyParameters: request
        )
    }

    static func putUserCategory(request: PutUserCategoryRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/interests",
            method: .put,
            bodyParameters: request
        )
    }

    static func putUserProfile(request: PutUserProfileRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/profiles",
            method: .put,
            bodyParameters: request
        )
    }

    static func getMyCommentedPopUp(request: UserSortedRequestDTO) -> Endpoint<GetMyCommentedPopUpResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/commented/popup",
            method: .get,
            queryParameters: request
        )
    }

    static func getBlockUserList(request: UserSortedRequestDTO) -> Endpoint<GetBlockUserListResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/blocked",
            method: .get,
            queryParameters: request
        )
    }

    static func getNoticeList() -> Endpoint<GetNoticeListResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/notice/list",
            method: .get
        )
    }

    static func getNoticeDetail(noticeID: Int64) -> Endpoint<GetNoticeDetailResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/notice/\(noticeID)",
            method: .get
        )
    }

    static func getRecentPopUp(request: UserSortedRequestDTO) -> Endpoint<GetRecentPopUpResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/recent-popupstores",
            method: .get,
            queryParameters: request
        )
    }

    static func getBookmarkPopUp(request: UserSortedRequestDTO) -> Endpoint<GetRecentPopUpResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/users/bookmark-popupstores",
            method: .get,
            queryParameters: request
        )
    }
}
