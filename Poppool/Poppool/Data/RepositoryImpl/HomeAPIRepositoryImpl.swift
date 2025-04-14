import Foundation

import RxSwift

final class HomeAPIRepositoryImpl: HomeAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    init(provider: Provider) {
        self.provider = provider
    }

    func fetchHome(request: SortedRequestDTO) -> Observable<GetHomeInfoResponse> {
        let endPoint = HomeAPIEndpoint.fetchHome(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    func fetchCustomPopUp(request: SortedRequestDTO) -> Observable<GetHomeInfoResponse> {
        let endPoint = HomeAPIEndpoint.fetchCustomPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    func fetchNewPopUp(request: SortedRequestDTO) -> Observable<GetHomeInfoResponse> {
        let endPoint = HomeAPIEndpoint.fetchNewPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    func fetchPopularPopUp(request: SortedRequestDTO) -> Observable<GetHomeInfoResponse> {
        let endPoint = HomeAPIEndpoint.fetchPopularPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
}
