import Infrastructure
import DomainInterface

import ReactorKit
import RxCocoa
import RxSwift

final class SubLoginReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case kakaoButtonTapped(controller: BaseViewController)
        case appleButtonTapped(controller: BaseViewController)
        case xmarkButtonTapped(controller: BaseViewController)
        case viewWillAppear
        case inquiryButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case moveToSignUpScene(controller: BaseViewController)
        case dismissScene(controller: BaseViewController)
        case loadView
        case resetService
        case moveToInquiryScene(controller: BaseViewController)
    }

    struct State {
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    private var authrizationCode: String?

    private let kakaoLoginService = KakaoLoginService()
    private var appleLoginService = AppleLoginService()
    private let authAPIUseCase: AuthAPIUseCase
    @Dependency private var keyChainService: KeyChainService
    let userDefaultService = UserDefaultService()

    // MARK: - init
    init(
        authAPIUseCase: AuthAPIUseCase
    ) {
        self.authAPIUseCase = authAPIUseCase
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
        case .viewWillAppear:
            return Observable.just(.resetService)
        case .inquiryButtonTapped(let controller):
            return Observable.just(.moveToInquiryScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .moveToSignUpScene(let controller):
            let signUpController = SignUpMainController()
            signUpController.reactor = SignUpMainReactor(
                isFirstResponderCase: false,
                authrizationCode: authrizationCode,
                signUpAPIUseCase: DIContainer.resolve(SignUpAPIUseCase.self)
            )
            controller.navigationController?.pushViewController(signUpController, animated: true)
        case .dismissScene(let controller):
            controller.dismiss(animated: true)
        case .loadView:
            break
        case .resetService:
            authrizationCode = nil
            appleLoginService = AppleLoginService()
        case .moveToInquiryScene(let controller):
            let nextController = FAQController()
            nextController.reactor = FAQReactor()
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        return state
    }

    func loginWithKakao(controller: BaseViewController) -> Observable<Mutation> {
        return kakaoLoginService.fetchUserCredential()
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
        return appleLoginService.fetchUserCredential()
            .withUnretained(self)
            .flatMap { owner, response in
                owner.authrizationCode = response.authorizationCode
                return owner.authAPIUseCase.postTryLogin(userCredential: response, socialType: "apple")
            }
            .withUnretained(self)
        
            .map { [weak controller] (owner:SubLoginReactor, loginResponse:LoginResponse) -> Mutation in
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
