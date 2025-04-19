import Foundation

import RxSwift

protocol CommentAPIUseCase {
    func postCommentAdd(popUpStoreId: Int64, content: String?, commentType: String?, imageUrlList: [String?]) -> Completable
    func deleteComment(popUpStoreId: Int64, commentId: Int64) -> Completable
    func editComment(popUpStoreId: Int64, commentId: Int64, content: String?, imageUrlList: [String?]?) -> Completable
}
