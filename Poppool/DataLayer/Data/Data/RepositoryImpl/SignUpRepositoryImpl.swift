import Foundation

import DomainInterface

import RxSwift

public final class SignUpRepositoryImpl: SignUpRepository {

    private let provider: Provider

    public init(provider: Provider) {
        self.provider = provider
    }

    public func checkNickName(nickName: String) -> Observable<Bool> {
        let endPoint = SignUpAPIEndpoint.signUp_checkNickName(with: .init(nickName: nickName))
        return provider.requestData(with: endPoint, interceptor: TokenInterceptor())
    }

    public func fetchCategoryList() -> Observable<[CategoryResponse]> {
        let endPoint = SignUpAPIEndpoint.signUp_getCategoryList()
        return provider.requestData(with: endPoint, interceptor: TokenInterceptor()).map { responseDTO in
            return responseDTO.categoryResponseList.map({ $0.toDomain() })
        }
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
        let endPoint = SignUpAPIEndpoint.signUp_trySignUp(with: .init(
            nickname: nickName,
            gender: gender,
            age: age,
            socialEmail: socialEmail,
            socialType: socialType,
            interestCategories: interests,
            appleAuthorizationCode: appleAuthorizationCode)
        )

        return provider.request(with: endPoint, interceptor: TokenInterceptor())
    }
}
