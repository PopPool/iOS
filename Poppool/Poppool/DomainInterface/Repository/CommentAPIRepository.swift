import Foundation

import RxSwift

protocol CommentAPIRepository {
    func postCommentAdd(request: PostCommentRequestDTO) -> Completable
    func deleteComment(request: DeleteCommentRequestDTO) -> Completable
    func editComment(request: PutCommentRequestDTO) -> Completable
}
