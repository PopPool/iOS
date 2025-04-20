import Foundation

import DomainInterface

import RxSwift

final class AdminUseCaseImpl: AdminUseCase {

    private let repository: AdminRepository

    init(repository: AdminRepository) {
        self.repository = repository
    }

    func fetchStoreList(query: String?, page: Int, size: Int) -> Observable<[AdminStore]> {
        return repository.fetchStoreList(query: query, page: page, size: size)
    }

    func fetchStoreDetail(id: Int64) -> Observable<AdminStoreDetail> {
        return repository.fetchStoreDetail(id: id)
    }

    func createStore(params: CreateStoreParams) -> Completable {
        Logger.log(message: "createStore 호출 - 스토어명: \(params.name)", category: .debug)
        return repository.createStore(params: params)
            .do(onError: { error in
                Logger.log(message: "createStore 실패 - Error: \(error)", category: .error)
            }, onCompleted: {
                Logger.log(message: "createStore 성공", category: .info)
            })
    }

    func updateStore(params: UpdateStoreParams) -> Completable {
        Logger.log(message: """
            Updating store with location:
            Latitude: \(params.latitude)
            Longitude: \(params.longitude)
            """, category: .debug)
        return repository.updateStore(params: params)
            .do(onError: { error in
                Logger.log(message: "Store update failed: \(error)", category: .error)
            }, onCompleted: {
                Logger.log(message: "Store update successful", category: .debug)
            })
    }

    func deleteStore(id: Int64) -> Completable {
        return repository.deleteStore(id: id)
    }

    // Notice
    func createNotice(params: CreateNoticeParams) -> Completable {
        return repository.createNotice(params: params)
    }

    func updateNotice(params: UpdateNoticeParams) -> Completable {
        return repository.updateNotice(params: params)
    }

    func deleteNotice(id: Int64) -> Completable {
        return repository.deleteNotice(id: id)
    }
}
