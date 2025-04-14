import Foundation

import RxSwift

protocol PopUpAPIRepository {
    func postBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> Completable
    func getClosePopUpList(request: GetSearchPopUpListRequestDTO) -> Observable<GetClosePopUpListResponseDTO>
    func getOpenPopUpList(request: GetSearchPopUpListRequestDTO) -> Observable<GetOpenPopUpListResponseDTO>
    func getSearchPopUpList(request: GetSearchPopUpListRequestDTO) -> Observable<GetSearchPopUpListResponseDTO>
    func getPopUpDetail(request: GetPopUpDetailRequestDTO) -> Observable<GetPopUpDetailResponseDTO>
    func getPopUpComment(request: GetPopUpCommentRequestDTO) -> Observable<GetPopUpCommentResponseDTO>
}
