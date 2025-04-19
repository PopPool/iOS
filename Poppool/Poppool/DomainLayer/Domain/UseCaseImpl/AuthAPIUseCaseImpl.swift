import Foundation
import RxSwift

final class AuthAPIUseCaseImpl: AuthAPIUseCase {

    private let repository: AuthAPIRepository

    init(repository: AuthAPIRepository) {
        self.repository = repository
    }

    func postTryLogin(userCredential: Encodable, socialType: String) -> Observable<LoginResponse> {
        return repository.tryLogIn(userCredential: userCredential, socialType: socialType)
    }

    func postTokenReissue() -> Observable<PostTokenReissueResponse> {
        return repository.postTokenReissue()
    }
}
