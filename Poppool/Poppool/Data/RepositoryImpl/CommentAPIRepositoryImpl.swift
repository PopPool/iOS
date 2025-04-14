import Foundation

import RxSwift

final class CommentAPIRepositoryImpl: CommentAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    init(provider: Provider) {
        self.provider = provider
    }

    func postCommentAdd(request: PostCommentRequestDTO) -> Completable {
        let endPoint = CommentAPIEndPoint.postCommentAdd(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func deleteComment(request: DeleteCommentRequestDTO) -> Completable {
        let endPoint = CommentAPIEndPoint.deleteComment(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func editComment(request: PutCommentRequestDTO) -> Completable {
        let endPoint = CommentAPIEndPoint.editComment(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
}
