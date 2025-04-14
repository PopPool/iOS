import Foundation

import RxSwift

protocol AdminUseCase {
    func fetchStoreList(query: String?, page: Int, size: Int) -> Observable<GetAdminPopUpStoreListResponseDTO>
    func fetchStoreDetail(id: Int64) -> Observable<GetAdminPopUpStoreDetailResponseDTO>
    func createStore(request: CreatePopUpStoreRequestDTO) -> Observable<EmptyResponse>
    func updateStore(request: UpdatePopUpStoreRequestDTO) -> Observable<EmptyResponse>
    func deleteStore(id: Int64) -> Observable<EmptyResponse>

    // Notice
    func createNotice(request: CreateNoticeRequestDTO) -> Observable<EmptyResponse>
    func updateNotice(id: Int64, request: UpdateNoticeRequestDTO) -> Observable<EmptyResponse>
    func deleteNotice(id: Int64) -> Observable<EmptyResponse>
}
