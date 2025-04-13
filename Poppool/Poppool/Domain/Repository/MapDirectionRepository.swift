//
//  MapDirectionRepository.swift
//  Poppool
//
//  Created by 김기현 on 1/23/25.
//

import Foundation
import RxSwift

protocol MapDirectionRepository {
    func getPopUpDirection(popUpStoreId: Int64) -> Observable<GetPopUpDirectionResponseDTO>
}

final class DefaultMapDirectionRepository: MapDirectionRepository {
    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    init(provider: Provider) {
        self.provider = provider
    }

    func getPopUpDirection(popUpStoreId: Int64) -> Observable<GetPopUpDirectionResponseDTO> {
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
