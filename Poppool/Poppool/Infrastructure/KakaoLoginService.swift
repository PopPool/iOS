//
//  KakaoLoginService.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 8/13/24.
//

import RxSwift
import KakaoSDKUser
//import RxKakaoSDKUser
import KakaoSDKAuth

final class KakaoLoginService: AuthServiceable {
    
    struct Credential: Encodable {
        var id: String
        var token: String
    }
    
    var disposeBag = DisposeBag()
    
    func unlink() -> Observable<Void> {
        return Observable.create { observer in
//            UserApi.shared.unlink { error in
//                if let error = error {
//                    observer.onNext(())
//                    Logger.log(message: error.localizedDescription, category: .error)
//                } else {
//                    observer.onNext(())
//                    observer.onCompleted()
//                }
//            }
            return Disposables.create()
        }
    }
    
    func fetchUserCredential() -> Observable<AuthServiceResponse> {
        return Observable.create { [weak self] observer in
//            guard let self = self else {
//                Logger.log(
//                    message: "KakaoTalk login Error",
//                    category: .error,
//                    fileName: #file,
//                    line: #line
//                )
//                return Disposables.create()
//            }
//            // 카카오톡 설치 유무
//            guard UserApi.isKakaoTalkLoginAvailable() else {
//                Logger.log(
//                    message: "KakaoTalk is not install",
//                    category: .error,
//                    fileName: #file,
//                    line: #line
//                )
//                UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
//                    if let error = error {
//                        observer.onError(error)
//                    } else {
//                        if let self = self, let accessToken = oauthToken?.accessToken {
//                            self.fetchUserId(observer: observer, accessToken: accessToken)
//                        }
//                    }
//                }
//                return Disposables.create()
//            }
//            // token을 획득하기 위한 로그인
//            loginWithKakaoTalk()
//                .withUnretained(self)
//                .subscribe { (owner, loginResponse) in
//                    owner.fetchUserId(observer: observer, accessToken: loginResponse.accessToken)
//                } onError: { _ in
//                    observer.onError(AuthError.unknownError)
//                }
//                .disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
}

private extension KakaoLoginService {
    
    func fetchUserId(observer: AnyObserver<AuthServiceResponse>, accessToken: String) {
//        UserApi.shared.rx.me()
//            .subscribe(onSuccess: { user in
//                observer.onNext(.init(kakaoUserId: user.id,kakaoAccessToken: accessToken))
//            }, onFailure: { _ in
//                observer.onError(AuthError.unknownError)
//            })
//            .disposed(by: self.disposeBag)
    }

    func loginWithKakaoTalk() -> Observable<OAuthToken> {
        return Observable.just(.init(accessToken: "", tokenType: "", refreshToken: "", scope: "", scopes: []))
//        return UserApi.shared.rx.loginWithKakaoTalk()
//            .do { token in
//                Logger.log(
//                    message: "KakaoTalk Login Response - \(token)",
//                    category: .info,
//                    fileName: #file,
//                    line: #line
//                )
//            } onError: { _ in
//                Logger.log(
//                    message: "KakaoTalk Login Fail",
//                    category: .error,
//                    fileName: #file,
//                    line: #line
//                )
//            }
    }
    
//    func fetchUserProfile() -> Single<User> {
//        return UserApi.shared.rx.me()
//            .do { user in
//                Logger.log(
//                    message: "KakaoTalk Profile Response - \(user)",
//                    category: .info,
//                    fileName: #file,
//                    line: #line
//                )
//            } onError: { _ in
//                Logger.log(
//                    message: "KakaoTalk Profile Fetch Fail",
//                    category: .error,
//                    fileName: #file,
//                    line: #line
//                )
//            }
//    }
}
