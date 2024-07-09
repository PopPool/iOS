//
//  SignUpRepositoryImpl.swift
//  PopPool
//
//  Created by SeoJunYoung on 6/28/24.
//

import Foundation
import RxSwift

final class SignUpRepositoryImpl: SignUpRepository {
    
    let provider = AppDIContainer.shared.resolve(type: Provider.self)
    
    func checkNickName(nickName: String) -> Observable<Bool> {
        let endPoint = PopPoolAPIEndPoint.checkNickName(with: .init(nickName: nickName))
        return provider.requestData(with: endPoint, interceptor: TokenInterceptor())
    }
    
    func fetchInterestList() -> Observable<[Interest]> {
        let endPoint = PopPoolAPIEndPoint.fetchInterestList()
        return provider.requestData(with: endPoint, interceptor: TokenInterceptor()).map { responseDTO in
            return responseDTO.interestResponse.map({ $0.toDomain() })
        }
    }
}
