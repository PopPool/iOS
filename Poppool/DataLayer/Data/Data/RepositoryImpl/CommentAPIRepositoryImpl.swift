import Foundation

import DomainInterface

import RxSwift

public final class CommentAPIRepositoryImpl: CommentAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    public init(provider: Provider) {
        self.provider = provider
    }

    func postCommentAdd(popUpStoreId: Int64, content: String?, commentType: String?, imageUrlList: [String?]) -> Completable {
        let requestDTO = PostCommentRequestDTO(popUpStoreId: popUpStoreId, content: content, commentType: commentType, imageUrlList: imageUrlList)
        let endPoint = CommentAPIEndPoint.postCommentAdd(request: requestDTO)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func deleteComment(popUpStoreId: Int64, commentId: Int64) -> Completable {
        let requestDTO = DeleteCommentRequestDTO(popUpStoreId: popUpStoreId, commentId: commentId)
        let endPoint = CommentAPIEndPoint.deleteComment(request: requestDTO)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func editComment(popUpStoreId: Int64, commentId: Int64, content: String?, imageUrlList: [PutCommentImageDataRequestDTO]?) -> Completable {
        let requestDTO = PutCommentRequestDTO(popUpStoreId: popUpStoreId, commentId: commentId, content: content, imageUrlList: imageUrlList)
        let endPoint = CommentAPIEndPoint.editComment(request: requestDTO)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
}
