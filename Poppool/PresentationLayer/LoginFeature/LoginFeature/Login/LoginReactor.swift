import DesignSystem
import DomainInterface
import Infrastructure
import LoginFeatureInterface
import PresentationInterface

import ReactorKit
import RxCocoa
import RxSwift

final class LoginReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case kakaoButtonTapped
        case appleButtonTapped
        case guestButtonTapped
        case xmarkButtonTapped
        case inquiryButtonTapped
    }

    enum Mutation {
        case moveToSignUpScene(from: LoginSceneType, authorizationCode: String?)
        case moveToHomeScene
        case moveToBeforeScene
        case moveToInquiryScene
        case showTooltip(of: TooltipType?)
    }

    struct State {
        var tooltipType: TooltipType?
        @Pulse var present: PresentTarget?
    }

    enum PresentTarget {
        case signUp(isFirstResponder: Bool, authorizationCode: String?)
        case home
        case dismiss
        case inquiry
    }

    enum TooltipType: String {
        case kakao, apple
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    private let loginSceneType: LoginSceneType
    private let authAPIUseCase: AuthAPIUseCase
    private let kakaoLoginUseCase: KakaoLoginUseCase
    private let appleLoginUseCase: AppleLoginUseCase

    @Dependency private var keyChainService: KeyChainService
    @Dependency private var userDefaultService: UserDefaultService

    // MARK: - init
    init(
        for loginSceneType: LoginSceneType,
        authAPIUseCase: AuthAPIUseCase,
        kakaoLoginUseCase: KakaoLoginUseCase,
        appleLoginUseCase: AppleLoginUseCase
    ) {
        self.initialState = State()
        self.loginSceneType = loginSceneType
        self.authAPIUseCase = authAPIUseCase
        self.kakaoLoginUseCase = kakaoLoginUseCase
        self.appleLoginUseCase = appleLoginUseCase
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return updateTooltip()

        case .kakaoButtonTapped:
            return loginWithKakao()

        case .appleButtonTapped:
            return loginWithApple()

        case .guestButtonTapped:
            keyChainService.deleteToken(type: .accessToken)
            keyChainService.deleteToken(type: .refreshToken)
            return Observable.just(.moveToHomeScene)

        case .xmarkButtonTapped:
            return Observable.just(.moveToBeforeScene)

        case .inquiryButtonTapped:
            return Observable.just(.moveToInquiryScene)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .showTooltip(let tooltipType):
            newState.tooltipType = tooltipType

        case .moveToSignUpScene(let loginSceneType, let authorizationCode):
            newState.present = .signUp(
                isFirstResponder: loginSceneType == .main,
                authorizationCode: authorizationCode
            )

        case .moveToHomeScene:
            newState.present = .home

        case .moveToBeforeScene:
            newState.present = .dismiss

        case .moveToInquiryScene:
            newState.present = .inquiry
        }

        return newState
    }

    func loginWithKakao() -> Observable<Mutation> {
        return kakaoLoginUseCase.fetchUserCredential()
            .withUnretained(self)
            .flatMap { (owner, authServiceResponse) in
                return owner.authAPIUseCase.postTryLogin(
                    userCredential: authServiceResponse,
                    socialType: "kakao"
                )
            }
            .withUnretained(self)
            .do { (owner, loginResponse) in
                owner.userDefaultService.save(keyType: .userID, value: loginResponse.userId)
                owner.userDefaultService.save(keyType: .socialType, value: loginResponse.socialType)
                owner.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)
            }
            .flatMap { (owner, loginResponse) -> Observable<Mutation> in
                let accessTokenResult = owner.keyChainService.saveToken(
                    type: .accessToken,
                    value: loginResponse.accessToken
                )

                switch accessTokenResult {
                case .success:
                    switch loginResponse.isRegisteredUser {
                    case true:
                        owner.userDefaultService.save(keyType: .lastLogin, value: "kakao")
                        return Observable.just(
                            owner.loginSceneType == .main ? .moveToHomeScene : .moveToBeforeScene
                        )

                    case false:
                        return Observable.just(
                            .moveToSignUpScene(
                                from: owner.loginSceneType,
                                authorizationCode: nil
                            )
                        )
                    }

                case .failure(let error):
                    // TODO: 로거 개선 후 로그인 실패 에러 남기기
                    return Observable.empty()
                }
            }
    }

    func loginWithApple() -> Observable<Mutation> {
        return appleLoginUseCase.fetchUserCredential()
            .withUnretained(self)
            .flatMap { (owner, authServiceResponse) -> Observable<(String?, LoginResponse)> in
                return owner.authAPIUseCase.postTryLogin(
                    userCredential: authServiceResponse,
                    socialType: "apple"
                )
                .map { (authServiceResponse.authorizationCode, $0) }
            }
            .withUnretained(self)
            .do { (owner, tuple) in
                let loginResponse = tuple.1
                owner.userDefaultService.save(keyType: .userID, value: loginResponse.userId)
                owner.userDefaultService.save(keyType: .socialType, value: loginResponse.socialType)
                owner.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)
            }
            .flatMap { (owner, tuple) -> Observable<Mutation> in
                let (authCode, loginResponse) = tuple

                let accessResult = owner.keyChainService.saveToken(
                    type: .accessToken,
                    value: loginResponse.accessToken
                )
                switch accessResult {
                case .success:
                    switch loginResponse.isRegisteredUser {
                    case true:
                        owner.userDefaultService.save(keyType: .lastLogin, value: "apple")
                        return .just(owner.loginSceneType == .main ?  .moveToHomeScene : .moveToBeforeScene)

                    case false:
                        return .just(
                            .moveToSignUpScene(
                                from: owner.loginSceneType,
                                authorizationCode: authCode
                            )
                        )
                    }

                case .failure:
                    // TODO: 로거 개선 후 로그인 실패 에러 남기기
                    return .empty()
                }
            }
    }
}

extension LoginReactor {
    private func updateTooltip() -> Observable<Mutation> {
        if let lastLogin = userDefaultService.fetch(keyType: .lastLogin) {
            return .just(.showTooltip(of: TooltipType(rawValue: lastLogin)))
        } else {
            return .empty()
        }
    }
}
