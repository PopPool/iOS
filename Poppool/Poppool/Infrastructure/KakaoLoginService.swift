import RxSwift
import KakaoSDKUser
import KakaoSDKAuth

final class KakaoLoginService: AuthServiceable {
    
    struct Credential: Encodable {
        var id: String
        var token: String
    }
    
    var disposeBag = DisposeBag()
    
    func unlink() -> Observable<Void> {
        return Observable.create { observer in
            UserApi.shared.unlink { error in
                if let error = error {
                    observer.onNext(())
                    Logger.log(message: error.localizedDescription, category: .error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchUserCredential() -> Observable<AuthServiceResponse> {
        return Observable.create { [weak self] observer in
            guard let self else {
                Logger.log(
                    message: "KakaoTalk login Error",
                    category: .error,
                    fileName: #file,
                    line: #line
                )
                return Disposables.create()
            }
            
            // 카카오톡 설치 유무 확인
            guard UserApi.isKakaoTalkLoginAvailable() else {
                Logger.log(
                    message: "KakaoTalk is not install",
                    category: .error,
                    fileName: #file,
                    line: #line
                )
                
                // 카카오톡 미설치시 계정으로 접속 시도
                UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        if let self = self, let accessToken = oauthToken?.accessToken {
                            self.fetchUserId(observer: observer, accessToken: accessToken)
                        }
                    }
                }
                
                return Disposables.create()
            }
            
            // token을 획득하기 위한 로그인
            loginWithKakaoTalk(observer: observer)
            
            return Disposables.create()
        }
    }
}

private extension KakaoLoginService {
    
    func fetchUserId(observer: AnyObserver<AuthServiceResponse>, accessToken: String) {
        UserApi.shared.me() { user, error in
            if let error = error {
                observer.onError(AuthError.unknownError)
            } else {
                // ???: 여기 onComplete로 observer를 종료하지 않아도 되는지?
                // ???: disposeBag으로 수거를 하지 않게 되는데 observer 수거에 대한 문제 발생 가능 여부 확인이 필요해보임
                observer.onNext(.init(kakaoUserId: user?.id, kakaoAccessToken: accessToken))
            }
        }
    }

    func loginWithKakaoTalk(observer: AnyObserver<AuthServiceResponse>) {
        UserApi.shared.loginWithKakaoTalk { oauthToken, error in
            if let error = error {
                Logger.log(
                    message: "KakaoTalk Login Fail",
                    category: .error,
                    fileName: #file,
                    line: #line
                )
                observer.onError(AuthError.unknownError)
            } else {
                if let oauthToken = oauthToken {
                    Logger.log(
                        message: "KakaoTalk Login Response - \(oauthToken)",
                        category: .info,
                        fileName: #file,
                        line: #line
                    )
                    self.fetchUserId(observer: observer, accessToken: oauthToken.accessToken)
                }
                

            }
        }
    }
    
    func fetchUserProfile() -> Single<User> {
        // MARK: 이런 식으로 구현하면 될거 같다 생각만 하고 여기서 멈췄습니다... ㅠㅠ
//        return Observable
//            .just(<#T##element: _##_#>)
//            .asSingle()
        return UserApi.shared.rx.me()
            .do { user in
                Logger.log(
                    message: "KakaoTalk Profile Response - \(user)",
                    category: .info,
                    fileName: #file,
                    line: #line
                )
            } onError: { _ in
                Logger.log(
                    message: "KakaoTalk Profile Fetch Fail",
                    category: .error,
                    fileName: #file,
                    line: #line
                )
            }
    }
}
