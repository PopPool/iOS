import Foundation

import DomainInterface

import RxSwift

public final class AuthAPIUseCaseImpl: AuthAPIUseCase {

    private let repository: AuthAPIRepository

    public init(repository: AuthAPIRepository) {
        self.repository = repository
    }

    public func postTryLogin(userCredential: Encodable, socialType: String) -> Observable<LoginResponse> {
        return repository.tryLogIn(userCredential: userCredential, socialType: socialType)
    }

    public func postTokenReissue() -> Observable<PostTokenReissueResponse> {
        return repository.postTokenReissue()
    }
}
