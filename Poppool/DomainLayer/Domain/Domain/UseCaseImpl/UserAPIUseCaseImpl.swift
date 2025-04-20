import Foundation

import DomainInterface

import RxSwift

final class UserAPIUseCaseImpl: UserAPIUseCase {
    private let repository: UserAPIRepository

    init(repository: UserAPIRepository) {
        self.repository = repository
    }

    func postBookmarkPopUp(popUpID: Int64) -> Completable {
        return repository.postBookmarkPopUp(popUpStoreId: popUpID)
    }

    func deleteBookmarkPopUp(popUpID: Int64) -> Completable {
        return repository.deleteBookmarkPopUp(popUpStoreId: popUpID)
    }

    func postCommentLike(commentId: Int64) -> Completable {
        return repository.postCommentLike(commentId: commentId)
    }

    func deleteCommentLike(commentId: Int64) -> Completable {
        return repository.deleteCommentLike(commentId: commentId)
    }

    func postUserBlock(blockedUserId: String?) -> Completable {
        return repository.postUserBlock(blockedUserId: blockedUserId)
    }

    func deleteUserBlock(blockedUserId: String?) -> Completable {
        return repository.deleteUserBlock(blockedUserId: blockedUserId)
    }

    func getOtherUserCommentedPopUpList(
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

    func getMyPage() -> Observable<GetMyPageResponse> {
        return repository.getMyPage()
    }

    func postLogout() -> Completable {
        return repository.postLogout()
    }

    func getWithdrawlList() -> Observable<GetWithdrawlListResponse> {
        return repository.getWithdrawlList()
    }

    func postWithdrawl(surveyList: [GetWithdrawlListDataResponse]) -> Completable {
        return repository.postWithdrawl(list: surveyList.map { ($0.id, $0.survey)})
    }

    func getMyProfile() -> Observable<GetMyProfileResponse> {
        return repository.getMyProfile()
    }

    func putUserTailoredInfo(gender: String?, age: Int32) -> Completable {
        return repository.putUserTailoredInfo(gender: gender, age: age)
    }

    func putUserCategory(
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

    func putUserProfile(profileImageUrl: String?, nickname: String?, email: String?, instagramId: String?, intro: String?) -> Completable {
        return repository.putUserProfile(profileImageUrl: profileImageUrl, nickname: nickname, email: email, instagramId: instagramId, intro: intro)
    }

    func getMyCommentedPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetMyCommentedPopUpResponse> {
        return repository.getMyCommentedPopUp(page: page, size: size, sort: sort)
    }

    func getBlockUserList(page: Int32?, size: Int32?, sort: String?) -> Observable<GetBlockUserListResponse> {
        return repository.getBlockUserList(page: page, size: size, sort: sort)
    }

    func getNoticeList() -> Observable<GetNoticeListResponse> {
        return repository.getNoticeList()
    }

    func getNoticeDetail(noticeID: Int64) -> Observable<GetNoticeDetailResponse> {
        return repository.getNoticeDetail(noticeID: noticeID)
    }

    func getRecentPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse> {
        return repository.getRecentPopUp(page: page, size: size, sort: sort)
    }

    func getBookmarkPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse> {
        return repository.getBookmarkPopUp(page: page, size: size, sort: sort)
    }
}
