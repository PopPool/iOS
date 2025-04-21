import Foundation

import DomainInterface

import RxSwift

public final class UserAPIUseCaseImpl: UserAPIUseCase {
    private let repository: UserAPIRepository

    public init(repository: UserAPIRepository) {
        self.repository = repository
    }

    public func postBookmarkPopUp(popUpID: Int64) -> Completable {
        return repository.postBookmarkPopUp(popUpStoreId: popUpID)
    }

    public func deleteBookmarkPopUp(popUpID: Int64) -> Completable {
        return repository.deleteBookmarkPopUp(popUpStoreId: popUpID)
    }

    public func postCommentLike(commentId: Int64) -> Completable {
        return repository.postCommentLike(commentId: commentId)
    }

    public func deleteCommentLike(commentId: Int64) -> Completable {
        return repository.deleteCommentLike(commentId: commentId)
    }

    public func postUserBlock(blockedUserId: String?) -> Completable {
        return repository.postUserBlock(blockedUserId: blockedUserId)
    }

    public func deleteUserBlock(blockedUserId: String?) -> Completable {
        return repository.deleteUserBlock(blockedUserId: blockedUserId)
    }

    public func getOtherUserCommentedPopUpList(
        commenterId: String?,
        commentType: String?,
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetOtherUserCommentedPopUpListResponse> {
        return repository.getOtherUserCommentList(
            commenterId: commenterId,
            commentType: commentType,
            page: page,
            size: size,
            sort: sort
        )
    }

    public func getMyPage() -> Observable<GetMyPageResponse> {
        return repository.getMyPage()
    }

    public func postLogout() -> Completable {
        return repository.postLogout()
    }

    public func getWithdrawlList() -> Observable<GetWithdrawlListResponse> {
        return repository.getWithdrawlList()
    }

    public func postWithdrawl(surveyList: [GetWithdrawlListDataResponse]) -> Completable {
        return repository.postWithdrawl(list: surveyList.map { ($0.id, $0.survey)})
    }

    public func getMyProfile() -> Observable<GetMyProfileResponse> {
        return repository.getMyProfile()
    }

    public func putUserTailoredInfo(gender: String?, age: Int32) -> Completable {
        return repository.putUserTailoredInfo(gender: gender, age: age)
    }

    public func putUserCategory(
        interestCategoriesToAdd: [Int64],
        interestCategoriesToDelete: [Int64],
        interestCategoriesToKeep: [Int64]
    ) -> Completable {
        return repository.putUserCategory(
            interestCategoriesToAdd: interestCategoriesToAdd,
            interestCategoriesToDelete: interestCategoriesToDelete,
            interestCategoriesToKeep: interestCategoriesToKeep
        )
    }

    public func putUserProfile(profileImageUrl: String?, nickname: String?, email: String?, instagramId: String?, intro: String?) -> Completable {
        return repository.putUserProfile(profileImageUrl: profileImageUrl, nickname: nickname, email: email, instagramId: instagramId, intro: intro)
    }

    public func getMyCommentedPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetMyCommentedPopUpResponse> {
        return repository.getMyCommentedPopUp(page: page, size: size, sort: sort)
    }

    public func getBlockUserList(page: Int32?, size: Int32?, sort: String?) -> Observable<GetBlockUserListResponse> {
        return repository.getBlockUserList(page: page, size: size, sort: sort)
    }

    public func getNoticeList() -> Observable<GetNoticeListResponse> {
        return repository.getNoticeList()
    }

    public func getNoticeDetail(noticeID: Int64) -> Observable<GetNoticeDetailResponse> {
        return repository.getNoticeDetail(noticeID: noticeID)
    }

    public func getRecentPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse> {
        return repository.getRecentPopUp(page: page, size: size, sort: sort)
    }

    public func getBookmarkPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse> {
        return repository.getBookmarkPopUp(page: page, size: size, sort: sort)
    }
}
