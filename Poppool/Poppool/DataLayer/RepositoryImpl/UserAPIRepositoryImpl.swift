import Foundation

import RxSwift

final class UserAPIRepositoryImpl: UserAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    init(provider: Provider) {
        self.provider = provider
    }

    func postBookmarkPopUp(popUpStoreId: Int64) -> Completable {
        let endPoint = UserAPIEndPoint.postBookmarkPopUp(request: .init(popUpStoreId: popUpStoreId))
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func deleteBookmarkPopUp(popUpStoreId: Int64) -> Completable {
        let endPoint = UserAPIEndPoint.deleteBookmarkPopUp(request: .init(popUpStoreId: popUpStoreId))
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func postCommentLike(commentId: Int64) -> Completable {
        let endPoint = UserAPIEndPoint.postCommentLike(request: .init(commentId: commentId))
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func deleteCommentLike(commentId: Int64) -> Completable {
        let endPoint = UserAPIEndPoint.deleteCommentLike(request: .init(commentId: commentId))
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func postUserBlock(blockedUserId: String?) -> Completable {
        let endPoint = UserAPIEndPoint.postUserBlock(request: .init(blockedUserId: blockedUserId))
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func deleteUserBlock(blockedUserId: String?) -> Completable {
        let endPoint = UserAPIEndPoint.deleteUserBlock(request: .init(blockedUserId: blockedUserId))
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func getOtherUserCommentList(
        commenterId: String?,
        commentType: String?,
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetOtherUserCommentedPopUpListResponse> {
        let request = GetOtherUserCommentListRequestDTO(commenterId: commenterId, commentType: commentType, page: page, size: size, sort: sort)
        let endPoint = UserAPIEndPoint.getOtherUserCommentPopUpList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func getMyPage() -> Observable<GetMyPageResponse> {
        let endPoint = UserAPIEndPoint.getMyPage()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func postLogout() -> Completable {
        let endPoint = UserAPIEndPoint.postLogout()
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func getWithdrawlList() -> Observable<GetWithdrawlListResponse> {
        let endPoint = UserAPIEndPoint.getWithdrawlList()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func postWithdrawl(list: [(Int64, String?)]) -> Completable {
        let endPoint = UserAPIEndPoint.postWithdrawl(request: .init(checkedSurveyList: list.map { .init(id: $0.0, survey: $0.1)}))
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func getMyProfile() -> Observable<GetMyProfileResponse> {
        let endPoint = UserAPIEndPoint.getMyProfile()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func putUserTailoredInfo(gender: String?, age: Int32) -> Completable {
        let endPoint = UserAPIEndPoint.putUserTailoredInfo(request: .init(gender: gender, age: age))
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func putUserCategory(
        interestCategoriesToAdd: [Int64],
        interestCategoriesToDelete: [Int64],
        interestCategoriesToKeep: [Int64]
    ) -> Completable {
        let request = PutUserCategoryRequestDTO(
            interestCategoriesToAdd: interestCategoriesToAdd,
            interestCategoriesToDelete: interestCategoriesToDelete,
            interestCategoriesToKeep: interestCategoriesToKeep
        )
        let endPoint = UserAPIEndPoint.putUserCategory(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func putUserProfile(
        profileImageUrl: String?,
        nickname: String?,
        email: String?,
        instagramId: String?,
        intro: String?
    ) -> Completable {
        let request = PutUserProfileRequestDTO(profileImageUrl: profileImageUrl, nickname: nickname, email: email, instagramId: instagramId, intro: intro)
        let endPoint = UserAPIEndPoint.putUserProfile(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func getMyCommentedPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetMyCommentedPopUpResponse> {
        let request = UserSortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = UserAPIEndPoint.getMyCommentedPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func getBlockUserList(page: Int32?, size: Int32?, sort: String?) -> Observable<GetBlockUserListResponse> {
        let request = UserSortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = UserAPIEndPoint.getBlockUserList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func getNoticeList() -> Observable<GetNoticeListResponse> {
        let endPoint = UserAPIEndPoint.getNoticeList()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func getNoticeDetail(noticeID: Int64) -> Observable<GetNoticeDetailResponse> {
        let endPoint = UserAPIEndPoint.getNoticeDetail(noticeID: noticeID)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func getRecentPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse> {
        let request = UserSortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = UserAPIEndPoint.getRecentPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    func getBookmarkPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetRecentPopUpResponse> {
        let request = UserSortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = UserAPIEndPoint.getBookmarkPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }
}
