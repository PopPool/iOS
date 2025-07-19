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
        case moveToSignUpScene(authrizationCode: String?)
        case moveToHomeScene
        case moveToInquiryScene
    }

    struct State {
        @Pulse var present: PresentTarget?
    }

    enum PresentTarget {
        case signUp(authrizationCode: String?)
        case home
        case inquiry
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

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
        case .moveToSignUpScene(let authrizationCode):
            newState.present = .signUp(authrizationCode: authrizationCode)

        case .moveToHomeScene:
            newState.present = .home

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
                    owner.userDefaultService.save(keyType: .lastLogin, value: "kakao")

                    switch loginResponse.isRegisteredUser {
                    case true: return Observable.just(.moveToHomeScene)
                    case false: return Observable.just(.moveToSignUpScene(authrizationCode: nil))
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
                let (authCode, loginResponse) = tuple
                self.userDefaultService.save(keyType: .userID, value: loginResponse.userId)
                self.userDefaultService.save(keyType: .socialType, value: loginResponse.socialType)
                self.keyChainService.saveToken(type: .refreshToken, value: loginResponse.refreshToken)
            }
            .flatMap { (owner, tuple) -> Observable<Mutation> in
                let (authCode, loginResponse) = tuple

                let accessResult = self.keyChainService.saveToken(
                    type: .accessToken,
                    value: loginResponse.accessToken
                )
                switch accessResult {
                case .success:
                    self.userDefaultService.save(keyType: .lastLogin, value: "apple")

                    switch loginResponse.isRegisteredUser {
                    case true: return .just(.moveToHomeScene)
                    case false: return .just(.moveToSignUpScene(authrizationCode: authCode))
                    }

                case .failure:
                    // TODO: 로거 개선 후 로그인 실패 에러 남기기
                    return .empty()
                }
            }
    }
}
