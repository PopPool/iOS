import DesignSystem
import DomainInterface
import LoginFeatureInterface
import Infrastructure

public final class SubLoginFactoryImpl: SubLoginFactory {

    public init() { }

    public func make() -> BaseViewController {
        let viewController = SubLoginController()
        viewController.reactor = SubLoginReactor(
            authAPIUseCase: DIContainer.resolve(AuthAPIUseCase.self),
            kakaoLoginUseCase: DIContainer.resolve(KakaoLoginUseCase.self),
            appleLoginUseCase: DIContainer.resolve(AppleLoginUseCase.self)
        )

        return viewController
    }
}
