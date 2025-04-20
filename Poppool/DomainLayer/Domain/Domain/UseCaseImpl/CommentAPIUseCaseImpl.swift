import Foundation

import DomainInterface

import RxSwift

public final class CommentAPIUseCaseImpl: CommentAPIUseCase {

    private let repository: CommentAPIRepository

    public init(repository: CommentAPIRepository) {
        self.repository = repository
    }

    public func postCommentAdd(popUpStoreId: Int64, content: String?, commentType: String?, imageUrlList: [String?]) -> Completable {
        return repository.postCommentAdd(popUpStoreId: popUpStoreId, content: content, commentType: commentType, imageUrlList: imageUrlList)
    }

    public func deleteComment(popUpStoreId: Int64, commentId: Int64) -> Completable {
        return repository.deleteComment(popUpStoreId: popUpStoreId, commentId: commentId)
    }

    public func editComment(popUpStoreId: Int64, commentId: Int64, content: String?, imageUrlList: [String?]?) -> Completable {
        return repository.editComment(popUpStoreId: popUpStoreId, commentId: commentId, content: content, imageUrlList: imageUrlList)
    }
}
