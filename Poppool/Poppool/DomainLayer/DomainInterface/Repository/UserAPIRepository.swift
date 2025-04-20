import Foundation

import RxSwift

protocol UserAPIRepository {
    func postBookmarkPopUp(popUpStoreId: Int64) -> Completable
    func deleteBookmarkPopUp(popUpStoreId: Int64) -> Completable
    func postCommentLike(commentId: Int64) -> Completable
    func deleteCommentLike(commentId: Int64) -> Completable
    func postUserBlock(blockedUserId: String?) -> Completable
    func deleteUserBlock(blockedUserId: String?) -> Completable

    func getOtherUserCommentList(
        commenterId: String?,
        commentType: String?,
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetOtherUserCommentedPopUpListResponse>

    func getMyPage() -> Observable<GetMyPageResponse>
    func postLogout() -> Completable
    func getWithdrawlList() -> Observable<GetWithdrawlListResponse>
    func postWithdrawl(list: [(Int64, String?)]) -> Completable

    func getMyProfile() -> Observable<GetMyProfileResponse>
    func putUserTailoredInfo(gender: String?, age: Int32) -> Completable

    func putUserCategory(
        interestCategoriesToAdd: [Int64],
        interestCategoriesToDelete: [Int64],
        interestCategoriesToKeep: [Int64]
    ) -> Completable

    func putUserProfile(
        profileImageUrl: String?,
        nickname: String?,
        email: String?,
        instagramId: String?,
        intro: String?
    ) -> Completable

    func getMyCommentedPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetMyCommentedPopUpResponse>
    func getBlockUserList(page: Int32?, size: Int32?, sort: String?) -> Observable<GetBlockUserListResponse>
    func getNoticeList() -> Observable<GetNoticeListResponse>
    func getNoticeDetail(noticeID: Int64) -> Observable<GetNoticeDetailResponse>
    func getRecentPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse>
    func getBookmarkPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse>
}
