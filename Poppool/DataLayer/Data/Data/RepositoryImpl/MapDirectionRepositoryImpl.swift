import Foundation

import DomainInterface

import RxSwift

public final class MapDirectionRepositoryImpl: MapDirectionRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    public init(provider: Provider) {
        self.provider = provider
    }

    public func getPopUpDirection(popUpStoreId: Int64) -> Observable<GetPopUpDirectionResponse> {
        let endpoint = FindDirectionEndPoint.fetchDirection(popUpStoreId: popUpStoreId)
        return provider.requestData(with: endpoint, interceptor: tokenInterceptor).map({ $0.toDomain() })
    }
}
