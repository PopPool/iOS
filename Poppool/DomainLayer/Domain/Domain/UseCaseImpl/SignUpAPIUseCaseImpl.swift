import Foundation

import DomainInterface

import RxSwift

public final class SignUpAPIUseCaseImpl: SignUpAPIUseCase {
    private let repository: SignUpRepository

    public init(repository: SignUpRepository) {
        self.repository = repository
    }

    public func trySignUp(
        nickName: String,
        gender: String,
        age: Int32,
        socialEmail: String,
        socialType: String,
        interests: [Int],
        appleAuthorizationCode: String?
    ) -> Completable {
        return repository.trySignUp(
            nickName: nickName,
            gender: gender,
            age: age,
            socialEmail: socialEmail,
            socialType: socialType,
            interests: interests,
            appleAuthorizationCode: appleAuthorizationCode
        )
    }

    public func checkNickName(nickName: String) -> Observable<Bool> {
        return repository.checkNickName(nickName: nickName)
    }

    public func fetchCategoryList() -> Observable<[CategoryResponse]> {
        return repository.fetchCategoryList()
    }
}
