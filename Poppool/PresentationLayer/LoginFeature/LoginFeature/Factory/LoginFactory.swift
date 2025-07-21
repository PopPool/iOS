import UIKit

import DesignSystem
import DomainInterface
import LoginFeatureInterface
import Infrastructure

public final class LoginFactoryImpl: LoginFactory {

    public init() { }

    public func make(
        _ loginSceneType: LoginSceneType,
        text: String
    ) -> BaseViewController {
        let viewController = LoginViewController(loginSceneType: loginSceneType, text: text)

        viewController.reactor = LoginReactor(
            for: loginSceneType,
            authAPIUseCase: DIContainer.resolve(AuthAPIUseCase.self),
            kakaoLoginUseCase: DIContainer.resolve(KakaoLoginUseCase.self),
            appleLoginUseCase: DIContainer.resolve(AppleLoginUseCase.self)
        )

        return viewController
    }
}
