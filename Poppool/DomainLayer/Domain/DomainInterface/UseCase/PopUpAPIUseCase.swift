import Foundation

import RxSwift

public protocol PopUpAPIUseCase {
    func getSearchBottomPopUpList(isOpen: Bool, categories: [Int64], page: Int32?, size: Int32, sort: String?) -> Observable<GetSearchBottomPopUpListResponse>
    func getSearchPopUpList(query: String?) -> Observable<GetSearchPopUpListResponse>
    func getPopUpDetail(commentType: String?, popUpStoredId: Int64, isViewCount: Bool?) -> Observable<GetPopUpDetailResponse>
    func getPopUpComment(commentType: String?, page: Int32?, size: Int32?, sort: String?, popUpStoreId: Int64) -> Observable<GetPopUpCommentResponse>
}
