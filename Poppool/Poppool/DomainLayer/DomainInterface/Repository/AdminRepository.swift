import Foundation

import RxSwift

protocol AdminRepository {
    func fetchStoreList(query: String?, page: Int, size: Int) -> Observable<[AdminStore]>
    func fetchStoreDetail(id: Int64) -> Observable<AdminStoreDetail>

    func createStore(params: CreateStoreParams) -> Completable

    func updateStore(params: UpdateStoreParams) -> Completable

    func deleteStore(id: Int64) -> Completable

    func createNotice(params: CreateNoticeParams) -> Completable
    func updateNotice(params: UpdateNoticeParams) -> Completable
    func deleteNotice(id: Int64) -> Completable
}
