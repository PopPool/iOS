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

final class DefaultAdminUseCase: AdminUseCase {

    private let repository: AdminRepository

    init(repository: AdminRepository) {
        self.repository = repository
    }

    func fetchStoreList(query: String?, page: Int, size: Int) -> Observable<GetAdminPopUpStoreListResponseDTO> {
        return repository.fetchStoreList(query: query, page: page, size: size)
    }

    func fetchStoreDetail(id: Int64) -> Observable<GetAdminPopUpStoreDetailResponseDTO> {
        return repository.fetchStoreDetail(id: id)
    }

    func createStore(request: CreatePopUpStoreRequestDTO) -> Observable<EmptyResponse> {
        Logger.log(message: "createStore 호출 - 요청 데이터: \(request)", category: .debug)
        return repository.createStore(request: request)
            .do(onNext: { _ in
                Logger.log(message: "createStore 성공", category: .info)
            }, onError: { error in
                Logger.log(message: "createStore 실패 - Error: \(error)", category: .error)
            })
    }

    func updateStore(request: UpdatePopUpStoreRequestDTO) -> Observable<EmptyResponse> {
        Logger.log(message: """
            Updating store with location:
            Latitude: \(request.location.latitude)
            Longitude: \(request.location.longitude)
            """, category: .debug)

        return repository.updateStore(request: request)
            .do(onNext: { _ in
                Logger.log(message: "Store update successful", category: .debug)
            }, onError: { error in
                Logger.log(message: "Store update failed: \(error)", category: .error)
            })
    }

    func deleteStore(id: Int64) -> Observable<EmptyResponse> {
        return repository.deleteStore(id: id)
    }

    // Notice
    func createNotice(request: CreateNoticeRequestDTO) -> Observable<EmptyResponse> {
        return repository.createNotice(request: request)
    }

    func updateNotice(id: Int64, request: UpdateNoticeRequestDTO) -> Observable<EmptyResponse> {
        return repository.updateNotice(id: id, request: request)
    }

    func deleteNotice(id: Int64) -> Observable<EmptyResponse> {
        return repository.deleteNotice(id: id)
    }
}
