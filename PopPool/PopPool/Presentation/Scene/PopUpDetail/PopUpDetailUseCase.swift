import Foundation
import RxSwift

protocol PopUpDetailUseCase {
    func getPopupDetail(popUpStoreId: Int64, userId: String, commentType: CommentType) -> Observable<PopupDetail>
    func toggleBookmark(userId: String, popUpStoreId: Int64) -> Completable
}

final class DefaultPopUpDetailUseCase: PopUpDetailUseCase {
    private let repository: PopUpRepository

    init(repository: PopUpRepository) {
        self.repository = repository
    }
    func getPopupDetail(popUpStoreId: Int64, userId: String, commentType: CommentType) -> Observable<PopupDetail> {
          print("PopUpDetailUseCase: getPopupDetail 호출됨")
          return repository.getPopupDetail(popUpStoreId: popUpStoreId, userId: userId, commentType: commentType)
              .do(onNext: { detail in
                  print("PopUpDetailUseCase: 팝업 상세 정보 받음")
                  print("PopUpDetailUseCase: 이미지 개수: \(detail.imageList.count)")
                  print("PopUpDetailUseCase: 댓글 개수: \(detail.commentList.count)")
              }, onError: { error in
                  print("PopUpDetailUseCase: 팝업 상세 정보 요청 실패: \(error)")
              })
      }

    func toggleBookmark(userId: String, popUpStoreId: Int64) -> Completable {
        return repository.toggleBookmark(userId: userId, popUpStoreId: popUpStoreId)
    }
}
