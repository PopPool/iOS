import DesignSystem
import DomainInterface
import Infrastructure
import PresentationInterface

import ReactorKit
import RxCocoa
import RxSwift

final class SubLoginReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case kakaoButtonTapped(controller: BaseViewController)
        case appleButtonTapped(controller: BaseViewController)
        case xmarkButtonTapped(controller: BaseViewController)
        case inquiryButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case moveToSignUpScene(controller: BaseViewController)
        case dismissScene(controller: BaseViewController)
        case loadView
        case moveToInquiryScene(controller: BaseViewController)
    }

    struct State {
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
        case .kakaoButtonTapped(let controller):
            return loginWithKakao(controller: controller)
        case .appleButtonTapped(let controller):
            return loginWithApple(controller: controller)
        case .xmarkButtonTapped(let controller):
            return Observable.just(.dismissScene(controller: controller))
        case .inquiryButtonTapped(let controller):
            return Observable.just(.moveToInquiryScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .moveToSignUpScene(let controller):
            @Dependency var factory: SignUpFactory
            controller.navigationController?.pushViewController(
                factory.make(isFirstResponder: false, authrizationCode: authrizationCode),
                animated: true
            )
        case .dismissScene(let controller):
            controller.dismiss(animated: true)
        case .loadView:
            break
        case .moveToInquiryScene(let controller):
            @Dependency var factory: FAQFactory
            controller.navigationController?.pushViewController(factory.make(), animated: true)
        }
        return state
    }

    func loginWithKakao(controller: BaseViewController) -> Observable<Mutation> {
        return kakaoLoginUseCase.fetchUserCredential()
            .withUnretained(self)
            .flatMap { owner, response in
                owner.authAPIUseCase.postTryLogin(userCredential: response, socialType: "kakao")
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
        return appleLoginUseCase.fetchUserCredential()
            .withUnretained(self)
            .flatMap { owner, response in
                owner.authrizationCode = response.authorizationCode
                return owner.authAPIUseCase.postTryLogin(userCredential: response, socialType: "apple")
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
