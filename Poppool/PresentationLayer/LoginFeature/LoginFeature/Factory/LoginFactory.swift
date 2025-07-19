import UIKit

import DesignSystem
import DomainInterface
import LoginFeatureInterface
import Infrastructure

public final class LoginFactoryImpl: LoginFactory {

    public init() { }

    public func make(isSubLogin: Bool) -> BaseViewController {
        let viewController = LoginViewController()
        viewController.reactor = LoginReactor(
            isSubLogin: isSubLogin,
            authAPIUseCase: DIContainer.resolve(AuthAPIUseCase.self),
            kakaoLoginUseCase: DIContainer.resolve(KakaoLoginUseCase.self),
            appleLoginUseCase: DIContainer.resolve(AppleLoginUseCase.self)
        )

        return viewController
    }
}
