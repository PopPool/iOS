//
//  LoginReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/24/24.
//

import ReactorKit
import RxSwift
import RxCocoa

final class LoginReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case kakaoButtonTapped(controller: BaseViewController)
        case appleButtonTapped(controller: BaseViewController)
        case guestButtonTapped(controller: BaseViewController)
        case viewWillAppear
    }
    
    enum Mutation {
        case moveToSignUpScene(controller: BaseViewController)
        case moveToHomeScene(controller: BaseViewController)
        case loadView
        case resetService
    }
    
    struct State {
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
    private var authrizationCode: String?
    
    private let kakaoLoginService = KakaoLoginService()
    private var appleLoginService = AppleLoginService()
    private let authApiUseCase = AuthAPIUseCaseImpl(repository: AuthAPIRepositoryImpl(provider: ProviderImpl()))
    private let keyChainService = KeyChainService()
    let userDefaultService = UserDefaultService()
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoButtonTapped(let controller):
            return loginWithKakao(controller: controller)
        case .appleButtonTapped(let controller):
            return loginWithApple(controller: controller)
        case .guestButtonTapped(let controller):
            let _ = keyChainService.deleteToken(type: .accessToken)
            let _ = keyChainService.deleteToken(type: .refreshToken)
            return Observable.just(.moveToHomeScene(controller: controller))
        case .viewWillAppear:
            return Observable.just(.resetService)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .moveToSignUpScene(let controller):
            let signUpController = SignUpMainController()
            signUpController.reactor = SignUpMainReactor(isFirstResponderCase: true, authrizationCode: authrizationCode)
            controller.navigationController?.pushViewController(signUpController, animated: true)
        case .moveToHomeScene(let controller):
            let homeTabbar = WaveTabBarController()
            controller.view.window?.rootViewController = homeTabbar
        case .loadView:
            break
        case .resetService:
            authrizationCode = nil
            appleLoginService = AppleLoginService()
        }
        return state
    }
    
    func loginWithKakao(controller: BaseViewController) -> Observable<Mutation> {
        return kakaoLoginService.fetchUserCredential()
            .withUnretained(self)
            .flatMap { owner, response in
                return owner.authApiUseCase.postTryLogin(userCredential: response, socialType: "kakao")
            }
            .withUnretained(self)
            .map { [weak controller] (owner, loginResponse) in
                guard let controller = controller else { return .loadView }
                owner.userDefaultService.save(key: "userID", value: loginResponse.userId)
                owner.userDefaultService.save(key: "socialType", value: loginResponse.socialType)
                let accessTokenResult = owner.keyChainService.saveToken(type: .accessToken, value: loginResponse.accessToken)
                let refreshTokenResult = owner.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)
                switch accessTokenResult {
                case .success:
                    owner.userDefaultService.save(key: "lastLogin", value: "kakao")
                    if loginResponse.isRegisteredUser {
                        return .moveToHomeScene(controller: controller)
                    } else {
                        return .moveToSignUpScene(controller: controller)
                    }
                case .failure:
                    return .loadView
                }
            }
    }
    
    func loginWithApple(controller: BaseViewController) -> Observable<Mutation> {
        return appleLoginService.fetchUserCredential()
            .withUnretained(self)
            .flatMap { owner, response in
                owner.authrizationCode = response.authorizationCode
                return owner.authApiUseCase.postTryLogin(userCredential: response, socialType: "apple")
            }
            .withUnretained(self)
            .map { [weak controller] (owner, loginResponse) in
                guard let controller = controller else { return .loadView }
                owner.userDefaultService.save(key: "userID", value: loginResponse.userId)
                owner.userDefaultService.save(key: "socialType", value: loginResponse.socialType)
                let accessTokenResult = owner.keyChainService.saveToken(type: .accessToken, value: loginResponse.accessToken)
                let refreshTokenResult = owner.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)
                switch accessTokenResult {
                case .success:
                    owner.userDefaultService.save(key: "lastLogin", value: "apple")
                    if loginResponse.isRegisteredUser {
                        return .moveToHomeScene(controller: controller)
                    } else {
                        return .moveToSignUpScene(controller: controller)
                    }
                case .failure:
                    return .loadView
                }
            }
    }
}
