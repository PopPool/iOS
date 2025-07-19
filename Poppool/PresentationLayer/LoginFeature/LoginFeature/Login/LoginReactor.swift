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
            .do { (owner, _) in owner.authrizationCode = nil }
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
                    owner.userDefaultService.save(keyType: .lastLogin, value: "kakao")

                    switch loginResponse.isRegisteredUser {
                    case true: return Observable.just(.moveToHomeScene)
                    case false: return Observable.just(.moveToSignUpScene)
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
            .do { (owner, authServiceResponse) in
                owner.authrizationCode = authServiceResponse.authorizationCode
            }
            .flatMap { (owner, authServiceResponse) in
                return owner.authAPIUseCase.postTryLogin(
                    userCredential: authServiceResponse,
                    socialType: "apple"
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
                    owner.userDefaultService.save(keyType: .lastLogin, value: "apple")

                    switch loginResponse.isRegisteredUser {
                    case true: return Observable.just(.moveToHomeScene)
                    case false: return Observable.just(.moveToSignUpScene)
                    }

                case .failure(let error):
                    // TODO: 로거 개선 후 로그인 실패 에러 남기기
                    return Observable.empty()
                }
            }
    }
}
