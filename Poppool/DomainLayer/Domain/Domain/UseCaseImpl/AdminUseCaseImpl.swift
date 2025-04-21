import Foundation

import DomainInterface
import Infrastructure

import RxSwift

public final class AdminUseCaseImpl: AdminUseCase {

    private let repository: AdminRepository

    public init(repository: AdminRepository) {
        self.repository = repository
    }

    public func fetchStoreList(query: String?, page: Int, size: Int) -> Observable<[AdminStore]> {
        return repository.fetchStoreList(query: query, page: page, size: size)
    }

    public func fetchStoreDetail(id: Int64) -> Observable<AdminStoreDetail> {
        return repository.fetchStoreDetail(id: id)
    }

    public func createStore(params: CreateStoreParams) -> Completable {
        Logger.log(message: "createStore 호출 - 스토어명: \(params.name)", category: .debug)
        return repository.createStore(params: params)
            .do(onError: { error in
                Logger.log(message: "createStore 실패 - Error: \(error)", category: .error)
            }, onCompleted: {
                Logger.log(message: "createStore 성공", category: .info)
            })
    }

    public func updateStore(params: UpdateStoreParams) -> Completable {
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

    public func deleteStore(id: Int64) -> Completable {
        return repository.deleteStore(id: id)
    }

    // Notice
    public func createNotice(params: CreateNoticeParams) -> Completable {
        return repository.createNotice(params: params)
    }

    public func updateNotice(params: UpdateNoticeParams) -> Completable {
        return repository.updateNotice(params: params)
    }

    public func deleteNotice(id: Int64) -> Completable {
        return repository.deleteNotice(id: id)
    }
}
