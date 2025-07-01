import Foundation

import DomainInterface

import RxSwift

public final class AuthAPIRepositoryImpl: AuthAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    public init(provider: Provider) {
        self.provider = provider
    }

    public func tryLogIn(userCredential: Encodable, socialType: String) -> Observable<LoginResponse> {
        let endPoint = AuthAPIEndPoint.auth_tryLogin(with: userCredential, path: socialType)
        return provider
            .requestData(with: endPoint, interceptor: nil)
            .map { responseDTO in
                return responseDTO.toDomain()
            }
    }

    public func postTokenReissue() -> Observable<PostTokenReissueResponse> {
        let endPoint = AuthAPIEndPoint.postTokenReissue()
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
            .map { responseDTO in
                return responseDTO.toDomain()
            }
    }
}
