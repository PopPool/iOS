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
//        print("🌎 [Repository]: 요청 생성 - \(endpoint)")
        return provider.requestData(with: endpoint, interceptor: TokenInterceptor())
            .do(onNext: { _ in
//                print("✅ [Repository]: 응답 수신 - \(response)")
            }, onError: { error in
                print("❌ [Repository]: 요청 실패 - \(error)")
            })
    }

}
