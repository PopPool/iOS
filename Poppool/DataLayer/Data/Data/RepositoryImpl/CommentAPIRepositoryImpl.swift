import Foundation

import DomainInterface

import RxSwift

public final class CommentAPIRepositoryImpl: CommentAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    public init(provider: Provider) {
        self.provider = provider
    }

    public func postCommentAdd(popUpStoreId: Int64, content: String?, commentType: String?, imageUrlList: [String?]) -> Completable {
        let requestDTO = PostCommentRequestDTO(popUpStoreId: popUpStoreId, content: content, commentType: commentType, imageUrlList: imageUrlList)
        let endPoint = CommentAPIEndPoint.postCommentAdd(request: requestDTO)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    public func deleteComment(popUpStoreId: Int64, commentId: Int64) -> Completable {
        let requestDTO = DeleteCommentRequestDTO(popUpStoreId: popUpStoreId, commentId: commentId)
        let endPoint = CommentAPIEndPoint.deleteComment(request: requestDTO)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    public func editComment(popUpStoreId: Int64, commentId: Int64, content: String?, imageUrlList: [String?]?) -> Completable {
        let dtoList: [PutCommentImageDataRequestDTO]? = imageUrlList?.compactMap { $0 }.map { PutCommentImageDataRequestDTO(imageUrl: $0) }

        let requestDTO = PutCommentRequestDTO(
            popUpStoreId: popUpStoreId,
            commentId: commentId,
            content: content,
            imageUrlList: dtoList
        )
        let endPoint = CommentAPIEndPoint.editComment(request: requestDTO)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
}
