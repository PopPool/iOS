import Foundation

import DomainInterface

import RxSwift

public class KakaoLoginUseCaseImpl: KakaoLoginUseCase {
    private let repository: KakaoLoginRepository

    public init(repository: KakaoLoginRepository) {
        self.repository = repository
    }

    public func fetchUserCredential() -> Observable<AuthServiceResponse> {
        return repository.fetchUserCredential()
    }
}
