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
    
    func getOtherUserCommentList(
        commenterId: String?,
        commentType: String?,
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetOtherUserCommentListResponse> {
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
}
