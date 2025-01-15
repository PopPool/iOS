import Foundation
import RxSwift
import UIKit

protocol AdminRepository {
    // 기존 메서드들
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

final class DefaultAdminRepository: AdminRepository {

    // MARK: - Properties
    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    // MARK: - Init
    init(provider: Provider) {
        self.provider = provider
    }

    // MARK: - Store Methods
    func fetchStoreList(query: String?, page: Int, size: Int) -> Observable<GetAdminPopUpStoreListResponseDTO> {
        let endpoint = AdminAPIEndpoint.fetchStoreList(
            query: query,
            page: page,
            size: size
        )
        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        )
    }

    func fetchStoreDetail(id: Int64) -> Observable<GetAdminPopUpStoreDetailResponseDTO> {
        let endpoint = AdminAPIEndpoint.fetchStoreDetail(id: id)
        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        )
    }

    func createStore(request: CreatePopUpStoreRequestDTO) -> Observable<EmptyResponse> {
        
        Logger.log(message: "createStore API 호출 시작", category: .info)
        let endpoint = AdminAPIEndpoint.createStore(request: request)
        Logger.log(message: "Request URL: \(endpoint.baseURL + endpoint.path)", category: .info)
        Logger.log(message: "Request Body: \(request)", category: .info)

        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        ).do(
            onNext: { _ in
                Logger.log(message: "createStore API 호출 성공", category: .info)
            },
            onError: { error in
                Logger.log(message: "createStore API 호출 실패: \(error)", category: .error)
            }
        )
    }

    func updateStore(request: UpdatePopUpStoreRequestDTO) -> Observable<EmptyResponse> {
        let endpoint = AdminAPIEndpoint.updateStore(request: request)
        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        )
    }

    func deleteStore(id: Int64) -> Observable<EmptyResponse> {
        let endpoint = AdminAPIEndpoint.deleteStore(id: id)
        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        )
    }

    // MARK: - Notice Methods
    func createNotice(request: CreateNoticeRequestDTO) -> Observable<EmptyResponse> {
        let endpoint = AdminAPIEndpoint.createNotice(request: request)
        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        )
    }

    func updateNotice(id: Int64, request: UpdateNoticeRequestDTO) -> Observable<EmptyResponse> {
        let endpoint = AdminAPIEndpoint.updateNotice(id: id, request: request)
        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        )
    }

    func deleteNotice(id: Int64) -> Observable<EmptyResponse> {
        let endpoint = AdminAPIEndpoint.deleteNotice(id: id)
        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        )
    }
}
