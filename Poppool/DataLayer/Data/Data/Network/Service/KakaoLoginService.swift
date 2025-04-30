import DomainInterface
import Infrastructure

import KakaoSDKAuth
import KakaoSDKUser
import RxSwift

public final class KakaoLoginService: AuthServiceable {

    public init() { }

    var disposeBag = DisposeBag()

    func unlink() -> Observable<Void> {
        return Observable.create { observer in
            UserApi.shared.unlink { error in
                if let error = error {
                    observer.onNext(())
                    Logger.log(error.localizedDescription, category: .error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    public func fetchUserCredential() -> Observable<AuthServiceResponse> {
        return Observable.create { [weak self] observer in
            guard let self else {
                Logger.log(
                    "KakaoTalk login Error",
                    category: .error
                )
                return Disposables.create()
            }

            // 카카오톡 설치 유무 확인
            guard UserApi.isKakaoTalkLoginAvailable() else {
                Logger.log(
                    "KakaoTalk is not install",
                    category: .error
                )

                // 카카오톡 미설치시 웹으로 인증 시도
                loginWithKakaoTalkWeb(observer: observer)
                return Disposables.create()
            }

            // 카카오톡 설치시 앱으로 인증 시도
            loginWithKakaoTalkApp(observer: observer)

            return Disposables.create()
        }
    }
}

private extension KakaoLoginService {

    /// 제공된 액세스 토큰을 사용하여 사용자의 카카오 ID를 가져옵니다.
    /// - Parameters:
    ///   - observer: 인증 응답을 처리할 옵저버.
    ///   - accessToken: 카카오 로그인 과정에서 얻은 액세스 토큰.
    func fetchUserId(observer: AnyObserver<AuthServiceResponse>, accessToken: String) {
        UserApi.shared.me { user, error in
            if let error = error {
                observer.onError(AuthError.unknownError(description: error.localizedDescription))
            } else {
                observer.onNext(.init(kakaoUserId: user?.id, kakaoAccessToken: accessToken))
                observer.onCompleted()
            }
        }
    }

    /// 카카오톡 앱을 사용하여 로그인하고 액세스 토큰을 가져옵니다.
    /// - Parameter observer: 인증 응답을 처리할 옵저버.
    func loginWithKakaoTalkApp(observer: AnyObserver<AuthServiceResponse>) {
        UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
            if let error = error {
                observer.onError(AuthError.unknownError(description: error.localizedDescription))
            } else {
                if let accessToken = oauthToken?.accessToken {
                    self?.fetchUserId(observer: observer, accessToken: accessToken)
                }
            }
        }
    }

    /// 카카오톡 웹을 사용하여 로그인하고 액세스 토큰을 가져옵니다.
    /// - Parameter observer: 인증 응답을 처리할 옵저버.
    func loginWithKakaoTalkWeb(observer: AnyObserver<AuthServiceResponse>) {
        UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
            if let error = error {
                observer.onError(AuthError.unknownError(description: error.localizedDescription))
            } else {
                if let accessToken = oauthToken?.accessToken {
                    self?.fetchUserId(observer: observer, accessToken: accessToken)
                }
            }
        }
    }
}
