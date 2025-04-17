import Foundation

import RxSwift

protocol PopUpAPIRepository {
    func postBookmarkPopUp(popUpStoreId: Int64) -> Completable

    func getClosePopUpList(
        categories: String?,
        page: Int32?,
        size: Int32?,
        sort: String?,
        query: String?,
        sortCode: String?
    ) -> Observable<GetSearchBottomPopUpListResponse>

    func getOpenPopUpList(
        categories: String?,
        page: Int32?,
        size: Int32?,
        sort: String?,
        query: String?,
        sortCode: String?
    ) -> Observable<GetSearchBottomPopUpListResponse>

    func getSearchPopUpList(
        categories: String?,
        page: Int32?,
        size: Int32?,
        sort: String?,
        query: String?,
        sortCode: String?
    ) -> Observable<GetSearchPopUpListResponse>

    func getPopUpDetail(commentType: String?, popUpStoreId: Int64, viewCountYn: Bool?) -> Observable<GetPopUpDetailResponse>

    func getPopUpComment(
        commentType: String?,
        page: Int32?,
        size: Int32?,
        sort: String?,
        popUpStoreId: Int64
    ) -> Observable<GetPopUpCommentResponse>
}
