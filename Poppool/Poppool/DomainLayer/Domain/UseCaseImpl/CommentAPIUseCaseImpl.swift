import Foundation

import RxSwift

final class CommentAPIUseCaseImpl: CommentAPIUseCase {
    
    private let repository: CommentAPIRepository

    init(repository: CommentAPIRepository) {
        self.repository = repository
    }

    func postCommentAdd(popUpStoreId: Int64, content: String?, commentType: String?, imageUrlList: [String?]) -> Completable {
        return repository.postCommentAdd(request: .init(popUpStoreId: popUpStoreId, content: content, commentType: commentType, imageUrlList: imageUrlList))
    }

    func deleteComment(popUpStoreId: Int64, commentId: Int64) -> Completable {
        return repository.deleteComment(request: .init(popUpStoreId: popUpStoreId, commentId: commentId))
    }

    func editComment(popUpStoreId: Int64, commentId: Int64, content: String?, imageUrlList: [PutCommentImageDataRequestDTO]?) -> Completable {
        return repository.editComment(request: .init(popUpStoreId: popUpStoreId, commentId: commentId, content: content, imageUrlList: imageUrlList))
    }
}
