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
}
