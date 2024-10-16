//
//  UserRepositoryImpl.swift
//  PopPool
//
//  Created by SeoJunYoung on 7/23/24.
//

import Foundation
import RxSwift

final class UserRepositoryImpl: UserRepository {
    
    private let provider = AppDIContainer.shared.resolve(type: Provider.self)
    private let tokenInterceptor = TokenInterceptor()
    private let requestTokenInterceptor = RequestTokenInterceptor()
    
    func fetchMyPage(
        userId: String
    ) -> Observable<GetMyPageResponse> {
        let endPoint = PopPoolAPIEndPoint.user_getMyPage(userId: userId)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
    
    func fetchMyComment(
        userId: String,
        page: Int32,
        size: Int32,
        sort: [String]?,
        commentType: CommentType
    ) -> Observable<GetMyCommentResponse> {
        let endPoint = PopPoolAPIEndPoint.user_getMyComment(
            userId: userId,
            request: .init(page: page, size: size, sort: sort, commentType: commentType)
        )
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
    
    func tryWithdraw(userId: String, surveyList: CheckedSurveyListRequestDTO) -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_tryWithdraw(
            userId: userId,
            survey: surveyList
        )
        return provider.request(with: endPoint, interceptor: requestTokenInterceptor)
    }
    
    func fetchMyRecentViewPopUpStoreList(
        userId: String,
        page: Int32,
        size: Int32,
        sort: [String]?
    ) -> Observable<GetMyRecentViewPopUpStoreListResponse> {
        let endPoint = PopPoolAPIEndPoint.user_getMyRecentViewPopUpStoreList(
            userId: userId,
            request: .init(page: page, size: size, sort: sort)
        )
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
    
    func userBlock(
        blockerUserId: String,
        blockedUserId: String
    ) -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_block(request: .init(blockerUserId: blockerUserId, blockedUserId: blockedUserId))
        return provider.request(with: endPoint, interceptor: requestTokenInterceptor)
    }
    
    func fetchBlockedUserList(
        userId: String,
        page: Int32,
        size: Int32,
        sort: [String]?
    ) -> Observable<GetBlockedUserListResponse> {
        let endPoint = PopPoolAPIEndPoint.user_getBlockedUserList(request: .init(userId: userId, page: page, size: size, sort: sort))
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
    
    func logOut() -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_logOut()
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func userUnblock(
        blockerUserId: String,
        blockedUserId: String
    ) -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_unblock(request: .init(userId: blockerUserId, blockedUserId: blockedUserId))
        return provider.request(with: endPoint, interceptor: requestTokenInterceptor)
    }
    
    func fetchWithdrawlSurveryList() -> Observable<GetWithDrawlSurveyResponse> {
        let endPoint = PopPoolAPIEndPoint.user_getWithdrawlSurveryList()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
    
    func fetchProfile(userId: String) -> Observable<GetProfileResponse> {
        let endPoint = PopPoolAPIEndPoint.user_getProfile(userId: userId)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
    
    func updateMyInterest(
        userId: String,
        interestsToAdd: [Int64],
        interestsToDelete: [Int64],
        interestsToKeep: [Int64]
    ) -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_updateMyInterest(
            userId: userId,
            request: .init(
                interestCategoriesToAdd: interestsToAdd,
                interestCategoriesToDelete: interestsToDelete,
                interestCategoriesToKeep: interestsToKeep
            )
        )
        return provider.request(with: endPoint, interceptor: requestTokenInterceptor)
    }
    
    func updateMyProfile(
        userId: String,
        profileImage: String?,
        nickname: String,
        email: String?,
        instagramId: String?,
        intro: String?
    ) -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_updateMyProfile(
            userId: userId,
            request: .init(
                profileImageUrl: profileImage,
                nickname: nickname,
                email: email,
                instagramId: instagramId,
                intro: intro
            )
        )
        return provider.request(with: endPoint, interceptor: requestTokenInterceptor)
    }
    
    func updateMyTailoredInfo(
        userId: String,
        gender: String,
        age: Int32
    ) -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_updateMyTailoredInfo(userId: userId, request: .init(gender: gender, age: age))
        return provider.request(with: endPoint, interceptor: requestTokenInterceptor)
    }
    
    func fetchBookMarkPopUpStoreList(
        userId: String,
        page: Int32,
        size: Int32,
        sort: [String]?
    ) -> Observable<GetBookMarkPopUpStoreListResponse> {
        let endPoint = PopPoolAPIEndPoint.user_fetchBookMarkPopUpStoreList(userId: userId, reqeust: .init(page: page, size: size, sort: sort))
        return provider.requestData(with: endPoint, interceptor: requestTokenInterceptor).map { $0.toDomain() }
    }
    
    func updateBookMarkPopUpStore(
        userId: String,
        popUpStoreId: Int64
    ) -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_updateBookMarkPopUpStore(userId: userId, reqeust: .init(popUpStoreId: popUpStoreId))
        return provider.request(with: endPoint, interceptor: requestTokenInterceptor)
    }
    
    func deleteBookMarkPopUpStore(
        userId: String,
        popUpStoreId: Int64
    ) -> Completable {
        let endPoint = PopPoolAPIEndPoint.user_deleteBookMarkPopUpStore(userId: userId, reqeust: .init(popUpStoreId: popUpStoreId))
        return provider.request(with: endPoint, interceptor: requestTokenInterceptor)
    }
}

