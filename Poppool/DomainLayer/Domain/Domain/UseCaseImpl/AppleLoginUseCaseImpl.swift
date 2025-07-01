import Foundation

import DomainInterface

import RxSwift

public class AppleLoginUseCaseImpl: AppleLoginUseCase {
    private let repository: AppleLoginRepository

    public init(repository: AppleLoginRepository) {
        self.repository = repository
    }

    public func fetchUserCredential() -> Observable<AuthServiceResponse> {
        return repository.fetchUserCredential()
    }
}
