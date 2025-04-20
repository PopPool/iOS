import Foundation

import DomainInterface

import RxSwift

final class CommentAPIUseCaseImpl: CommentAPIUseCase {

    private let repository: CommentAPIRepository

    init(repository: CommentAPIRepository) {
        self.repository = repository
    }

    func postCommentAdd(popUpStoreId: Int64, content: String?, commentType: String?, imageUrlList: [String?]) -> Completable {
        return repository.postCommentAdd(popUpStoreId: popUpStoreId, content: content, commentType: commentType, imageUrlList: imageUrlList)
    }

    func deleteComment(popUpStoreId: Int64, commentId: Int64) -> Completable {
        return repository.deleteComment(popUpStoreId: popUpStoreId, commentId: commentId)
    }

    func editComment(popUpStoreId: Int64, commentId: Int64, content: String?, imageUrlList: [String?]?) -> Completable {
        let dtoList: [PutCommentImageDataRequestDTO]? = imageUrlList?.compactMap { $0 }.map { PutCommentImageDataRequestDTO(imageUrl: $0) }
        return repository.editComment(popUpStoreId: popUpStoreId, commentId: commentId, content: content, imageUrlList: dtoList)
    }
}
