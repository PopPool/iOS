//
//  UserAPIUseCaseImpl.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/3/24.
//

import RxSwift

final class UserAPIUseCaseImpl {

    var repository: UserAPIRepositoryImpl

    init(repository: UserAPIRepositoryImpl) {
        self.repository = repository
    }

    func postBookmarkPopUp(popUpID: Int64) -> Completable {
        return repository.postBookmarkPopUp(request: .init(popUpStoreId: popUpID))
    }

    func deleteBookmarkPopUp(popUpID: Int64) -> Completable {
        return repository.deleteBookmarkPopUp(request: .init(popUpStoreId: popUpID))
    }

    func postCommentLike(commentId: Int64) -> Completable {
        return repository.postCommentLike(request: .init(commentId: commentId))
    }

    func deleteCommentLike(commentId: Int64) -> Completable {
        return repository.deleteCommentLike(request: .init(commentId: commentId))
    }

    func postUserBlock(blockedUserId: String?) -> Completable {
        return repository.postUserBlock(request: .init(blockedUserId: blockedUserId))
    }

    func deleteUserBlock(blockedUserId: String?) -> Completable {
        return repository.deleteUserBlock(request: .init(blockedUserId: blockedUserId))
    }

    func getOtherUserCommentedPopUpList(
        commenterId: String?,
        commentType: String?,
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetOtherUserCommentedPopUpListResponse> {
        return repository.getOtherUserCommentList(
            request: .init(
                commenterId: commenterId,
                commentType: commentType,
                page: page,
                size: size,
                sort: sort)
        )
        .map { $0.toDomain() }
    }

    func getMyPage() -> Observable<GetMyPageResponse> {
        return repository.getMyPage().map { $0.toDomain() }
    }

    func postLogout() -> Completable {
        return repository.postLogout()
    }

    func getWithdrawlList() -> Observable<GetWithdrawlListResponse> {
        return repository.getWithdrawlList().map { $0.toDomain() }
    }

    func postWithdrawl(surveyList: [GetWithdrawlListDataResponse]) -> Completable {
        return repository.postWithdrawl(request: .init(checkedSurveyList: surveyList.map { .init(id: $0.id, survey: $0.survey)}))
    }

    func getMyProfile() -> Observable<GetMyProfileResponse> {
        return repository.getMyProfile().map { $0.toDomain() }
    }

    func putUserTailoredInfo(gender: String?, age: Int32) -> Completable {
        return repository.putUserTailoredInfo(request: .init(gender: gender, age: age))
    }

    func putUserCategory(
        interestCategoriesToAdd: [Int64],
        interestCategoriesToDelete: [Int64],
        interestCategoriesToKeep: [Int64]
    ) -> Completable {
        return repository.putUserCategory(
            request: .init(
                interestCategoriesToAdd: interestCategoriesToAdd,
                interestCategoriesToDelete: interestCategoriesToDelete,
                interestCategoriesToKeep: interestCategoriesToKeep
            )
        )
    }

    func putUserProfile(profileImageUrl: String?, nickname: String?, email: String?, instagramId: String?, intro: String?) -> Completable {
        return repository.putUserProfile(request: .init(profileImageUrl: profileImageUrl, nickname: nickname, email: email, instagramId: instagramId, intro: intro))
    }

    func getMyCommentedPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetMyCommentedPopUpResponse> {
        return repository.getMyCommentedPopUp(request: .init(page: page, size: size, sort: sort)).map { $0.toDomain() }
    }

    func getBlockUserList(page: Int32?, size: Int32?, sort: String?) -> Observable<GetBlockUserListResponse> {
        return repository.getBlockUserList(request: .init(page: page, size: size, sort: sort)).map { $0.toDomain() }
    }

    func getNoticeList() -> Observable<GetNoticeListResponse> {
        return repository.getNoticeList().map { $0.toDomain() }
    }

    func getNoticeDetail(noticeID: Int64) -> Observable<GetNoticeDetailResponse> {
        return repository.getNoticeDetail(noticeID: noticeID).map { $0.toDomain() }
    }

    func getRecentPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse> {
        return repository.getRecentPopUp(request: .init(page: page, size: size, sort: sort)).map { $0.toDomain() }
    }

    func getBookmarkPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse> {
        return repository.getBookmarkPopUp(request: .init(page: page, size: size, sort: sort)).map { $0.toDomain() }
    }
}
