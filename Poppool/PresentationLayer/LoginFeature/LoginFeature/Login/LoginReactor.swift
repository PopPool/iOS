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
        case loadView
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

        case .loadView:
            break
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
            .map { (owner, loginResponse) in
                owner.userDefaultService.save(key: "userID", value: loginResponse.userId)
                owner.userDefaultService.save(key: "socialType", value: loginResponse.socialType)
                let accessTokenResult = owner.keyChainService.saveToken(type: .accessToken, value: loginResponse.accessToken)
                let refreshTokenResult = owner.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)
                switch accessTokenResult {
                case .success:
                    owner.userDefaultService.save(key: "lastLogin", value: "kakao")
                    if loginResponse.isRegisteredUser {
                        return .moveToHomeScene
                    } else {
                        return .moveToSignUpScene
                    }
                case .failure:
                    return .loadView
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
            .map { (owner, loginResponse) in
                owner.userDefaultService.save(key: "userID", value: loginResponse.userId)
                owner.userDefaultService.save(key: "socialType", value: loginResponse.socialType)
                let accessTokenResult = owner.keyChainService.saveToken(type: .accessToken, value: loginResponse.accessToken)
                let refreshTokenResult = owner.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)
                switch accessTokenResult {
                case .success:
                    owner.userDefaultService.save(key: "lastLogin", value: "apple")
                    if loginResponse.isRegisteredUser {
                        return .moveToHomeScene
                    } else {
                        return .moveToSignUpScene
                    }
                case .failure:
                    return .loadView
                }
            }
    }
}
