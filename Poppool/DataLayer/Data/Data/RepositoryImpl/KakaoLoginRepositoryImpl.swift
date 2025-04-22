import Foundation

import DomainInterface

import RxSwift

public class KakaoLoginRepositoryImpl: KakaoLoginRepository {
    let service = KakaoLoginService()

    public init() { }

    public func fetchUserCredential() -> Observable<AuthServiceResponse> {
        return service.fetchUserCredential()
    }
}
