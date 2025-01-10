//
//  UserAPIRepositoryImpl.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/3/24.
//

import Foundation

import RxSwift

final class UserAPIRepositoryImpl {
    
    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()
    
    init(provider: Provider) {
        self.provider = provider
    }
 
    func postBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.postBookmarkPopUp(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func deleteBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.deleteBookmarkPopUp(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func postCommentLike(request: CommentLikeRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.postCommentLike(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func deleteCommentLike(request: CommentLikeRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.deleteCommentLike(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func postUserBlock(request: PostUserBlockRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.postUserBlock(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func deleteUserBlock(request: PostUserBlockRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.deleteUserBlock(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func getOtherUserCommentList(request: GetOtherUserCommentListRequestDTO) -> Observable<GetOtherUserCommentListResponseDTO> {
        let endPoint = UserAPIEndPoint.getOtherUserCommentList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func getMyPage() -> Observable<GetMyPageResponseDTO> {
        let endPoint = UserAPIEndPoint.getMyPage()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func postLogout() -> Completable {
        let endPoint = UserAPIEndPoint.postLogout()
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func getWithdrawlList() -> Observable<GetWithdrawlListResponseDTO> {
        let endPoint = UserAPIEndPoint.getWithdrawlList()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func postWithdrawl(request: PostWithdrawlListRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.postWithdrawl(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func getMyProfile() -> Observable<GetMyProfileResponseDTO> {
        let endPoint = UserAPIEndPoint.getMyProfile()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func putUserTailoredInfo(request: PutUserTailoredInfoRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.putUserTailoredInfo(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func putUserCategory(request: PutUserCategoryRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.putUserCategory(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
}
