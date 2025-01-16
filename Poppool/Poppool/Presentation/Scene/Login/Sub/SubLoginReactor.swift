//
//  SubLoginReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/28/24.
//

import ReactorKit
import RxSwift
import RxCocoa

final class SubLoginReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case kakaoButtonTapped(controller: BaseViewController)
        case appleButtonTapped(controller: BaseViewController)
        case xmarkButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case moveToSignUpScene(controller: BaseViewController)
        case dismissScene(controller: BaseViewController)
        case loadView
    }
    
    struct State {
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
    private let kakaoLoginService = KakaoLoginService()
    private let appleLoginService = AppleLoginService()
    private let authApiUseCase = AuthAPIUseCaseImpl(repository: AuthAPIRepositoryImpl(provider: ProviderImpl()))
    private let keyChainService = KeyChainService()
    private let userDefaultService = UserDefaultService()
    
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
        case .xmarkButtonTapped(let controller):
            return Observable.just(.dismissScene(controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .moveToSignUpScene(let controller):
            let signUpController = SignUpMainController()
            signUpController.reactor = SignUpMainReactor(isFirstResponderCase: false)
            controller.navigationController?.pushViewController(signUpController, animated: true)
        case .dismissScene(let controller):
            controller.dismiss(animated: true)
        case .loadView:
            break
        }
        return state
    }
    
    func loginWithKakao(controller: BaseViewController) -> Observable<Mutation> {
        return kakaoLoginService.fetchUserCredential()
            .withUnretained(self)
            .flatMap { owner, response in
                owner.authApiUseCase.postTryLogin(userCredential: response, socialType: "kakao")
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
                    if loginResponse.isRegisteredUser {
                        return .dismissScene(controller: controller)
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
                owner.authApiUseCase.postTryLogin(userCredential: response, socialType: "apple")
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
                    if loginResponse.isRegisteredUser {
                        return .dismissScene(controller: controller)
                    } else {
                        return .moveToSignUpScene(controller: controller)
                    }
                case .failure:
                    return .loadView
                }
            }
    }
}
