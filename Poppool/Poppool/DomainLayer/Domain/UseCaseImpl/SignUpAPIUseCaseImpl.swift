import Foundation

import RxSwift

final class SignUpAPIUseCaseImpl: SignUpAPIUseCase {
    private let repository: SignUpRepository

    init(repository: SignUpRepository) {
        self.repository = repository
    }
    
    func trySignUp(
        nickName: String,
        gender: String,
        age: Int32,
        socialEmail: String,
        socialType: String,
        interests: [Int64],
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
    
    func checkNickName(nickName: String) -> Observable<Bool> {
        return repository.checkNickName(nickName: nickName)
    }

    func fetchCategoryList() -> Observable<[CategoryResponse]> {
        return repository.fetchCategoryList()
    }
}
