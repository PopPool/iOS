import Foundation

import RxSwift

final class HomeAPIRepositoryImpl: HomeAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    init(provider: Provider) {
        self.provider = provider
    }

    func fetchHome(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse> {
        let request = SortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = HomeAPIEndpoint.fetchHome(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    func fetchCustomPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse> {
        let request = SortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = HomeAPIEndpoint.fetchCustomPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    func fetchNewPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse> {
        let request = SortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = HomeAPIEndpoint.fetchNewPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    func fetchPopularPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse> {
        let request = SortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = HomeAPIEndpoint.fetchPopularPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
}
