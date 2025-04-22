import Foundation

import DomainInterface

import RxSwift

public class AppleLoginRepositoryImpl: AppleLoginRepository {
    private let service = AppleLoginService()

    public init() { }

    public func fetchUserCredential() -> Observable<AuthServiceResponse> {
        return service.fetchUserCredential()
    }
}
