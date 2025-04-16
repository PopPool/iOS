import Foundation

import RxSwift

final class SignUpRepositoryImpl: SignUpRepository {

    private let provider: Provider

    init(provider: Provider) {
        self.provider = provider
    }

    func checkNickName(nickName: String) -> Observable<Bool> {
        let endPoint = SignUpAPIEndpoint.signUp_checkNickName(with: .init(nickName: nickName))
        return provider.requestData(with: endPoint, interceptor: TokenInterceptor())
    }

    func fetchCategoryList() -> Observable<[CategoryResponse]> {
        let endPoint = SignUpAPIEndpoint.signUp_getCategoryList()
        return provider.requestData(with: endPoint, interceptor: TokenInterceptor()).map { responseDTO in
            return responseDTO.categoryResponseList.map({ $0.toDomain() })
        }
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
        let endPoint = SignUpAPIEndpoint.signUp_trySignUp(with: .init(
            nickname: nickName,
            gender: gender,
            age: age,
            socialEmail: socialEmail,
            socialType: socialType,
            interestCategories: interests,
            appleAuthorizationCode: appleAuthorizationCode)
        )
        print(endPoint)
        return provider.request(with: endPoint, interceptor: TokenInterceptor())
    }
}
