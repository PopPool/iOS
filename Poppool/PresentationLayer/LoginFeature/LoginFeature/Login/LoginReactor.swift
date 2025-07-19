import DesignSystem
import DomainInterface
import Infrastructure
import PresentationInterface

import ReactorKit
import RxCocoa
import RxSwift

final class LoginReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case kakaoButtonTapped
        case appleButtonTapped
        case guestButtonTapped
        case inquiryButtonTapped
    }

    enum Mutation {
        case moveToSignUpScene
        case moveToHomeScene
        case moveToInquiryScene
    }

    struct State {
        @Pulse var presentSignUp: String?
        @Pulse var presentHome: Void?
        @Pulse var presentInquiry: Void?
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    private var authrizationCode: String?

    private let authAPIUseCase: AuthAPIUseCase
    private let kakaoLoginUseCase: KakaoLoginUseCase
    private let appleLoginUseCase: AppleLoginUseCase

    @Dependency private var keyChainService: KeyChainService
    let userDefaultService = UserDefaultService()

    // MARK: - init
    init(
        authAPIUseCase: AuthAPIUseCase,
        kakaoLoginUseCase: KakaoLoginUseCase,
        appleLoginUseCase: AppleLoginUseCase
    ) {
        self.authAPIUseCase = authAPIUseCase
        self.kakaoLoginUseCase = kakaoLoginUseCase
        self.appleLoginUseCase = appleLoginUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoButtonTapped:
            return loginWithKakao()
        case .appleButtonTapped:
            return loginWithApple()
        case .guestButtonTapped:
            keyChainService.deleteToken(type: .accessToken)
            keyChainService.deleteToken(type: .refreshToken)
            return Observable.just(.moveToHomeScene)
        case .inquiryButtonTapped:
            return Observable.just(.moveToInquiryScene)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .moveToSignUpScene:
            newState.presentSignUp = authrizationCode

        case .moveToHomeScene:
            newState.presentHome = ()

        case .moveToInquiryScene:
            newState.presentInquiry = ()
        }
        return newState
    }

    func loginWithKakao() -> Observable<Mutation> {
        return kakaoLoginUseCase.fetchUserCredential()
            .withUnretained(self)
            .flatMap { owner, response in
                return owner.authAPIUseCase.postTryLogin(userCredential: response, socialType: "kakao")
            }
            .withUnretained(self)
            .flatMap { (owner, loginResponse) -> Observable<Mutation> in
                owner.userDefaultService.save(key: "userID", value: loginResponse.userId)
                owner.userDefaultService.save(key: "socialType", value: loginResponse.socialType)
                owner.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)

                let accessTokenResult = owner.keyChainService.saveToken(
                    type: .accessToken,
                    value: loginResponse.accessToken
                )

                switch accessTokenResult {
                case .success:
                    owner.userDefaultService.save(key: "lastLogin", value: "kakao")

                    switch loginResponse.isRegisteredUser {
                    case true: return Observable.just(.moveToHomeScene)
                    case false: return Observable.just(.moveToSignUpScene)
                    }

                case .failure:
                    return Observable.empty()
                }
            }
    }

    func loginWithApple() -> Observable<Mutation> {
        return appleLoginUseCase.fetchUserCredential()
            .withUnretained(self)
            .flatMap { owner, response in
                owner.authrizationCode = response.authorizationCode
                return owner.authAPIUseCase.postTryLogin(userCredential: response, socialType: "apple")
            }
            .withUnretained(self)
            .flatMap { (owner, loginResponse) -> Observable<Mutation> in
                owner.userDefaultService.save(key: "userID", value: loginResponse.userId)
                owner.userDefaultService.save(key: "socialType", value: loginResponse.socialType)
                owner.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)

                let accessTokenResult = owner.keyChainService.saveToken(
                    type: .accessToken,
                    value: loginResponse.accessToken
                )
                switch accessTokenResult {
                case .success:
                    owner.userDefaultService.save(key: "lastLogin", value: "apple")

                    switch loginResponse.isRegisteredUser {
                    case true: return Observable.just(.moveToHomeScene)
                    case false: return Observable.just(.moveToSignUpScene)
                    }

                case .failure:
                    return Observable.empty()
                }
            }
    }
}
