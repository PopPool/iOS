import UIKit

import DesignSystem
import DomainInterface
import Infrastructure
import PresentationInterface

public final class SignUpFactoryImpl: SignUpFactory {

    public init() { }

    public func make(isFirstResponder: Bool, authrizationCode: String?) -> DesignSystem.BaseTabmanController {
        let viewController = SignUpMainController()

        viewController.reactor = SignUpMainReactor(
            isFirstResponderCase: isFirstResponder,
            authrizationCode: authrizationCode,
            signUpAPIUseCase: DIContainer.resolve(SignUpAPIUseCase.self)
        )

        return viewController
    }
}
