import Foundation
import RxSwift

protocol AdminUseCase {

    func fetchStoreList(query: String?, page: Int, size: Int) -> Observable<[StoreResponse]>
    func fetchStoreDetail(id: Int64) -> Observable<StoreDetailResponse>

    func createStore(params: CreateStoreParams) -> Completable

    func updateStore(params: UpdateStoreParams) -> Completable

    func deleteStore(id: Int64) -> Completable

    func createNotice(params: CreateNoticeParams) -> Completable
    func updateNotice(params: UpdateNoticeParams) -> Completable
    func deleteNotice(id: Int64) -> Completable
}
