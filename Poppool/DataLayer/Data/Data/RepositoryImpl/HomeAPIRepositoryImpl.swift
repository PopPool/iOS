import Foundation

import DomainInterface

import RxSwift

public final class HomeAPIRepositoryImpl: HomeAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    public init(provider: Provider) {
        self.provider = provider
    }

    public func fetchHome(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse> {
        let request = HomeSortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = HomeAPIEndpoint.fetchHome(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    public func fetchCustomPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse> {
        let request = HomeSortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = HomeAPIEndpoint.fetchCustomPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    public func fetchNewPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse> {
        let request = HomeSortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = HomeAPIEndpoint.fetchNewPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }

    public func fetchPopularPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse> {
        let request = HomeSortedRequestDTO(page: page, size: size, sort: sort)
        let endPoint = HomeAPIEndpoint.fetchPopularPopUp(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
}
