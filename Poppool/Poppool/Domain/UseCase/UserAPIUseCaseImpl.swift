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
}
