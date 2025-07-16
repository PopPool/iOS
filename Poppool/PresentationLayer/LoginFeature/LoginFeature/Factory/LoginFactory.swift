import UIKit

import DesignSystem
import LoginFeatureInterface

public final class LoginFactoryImpl: LoginFactory {

    public init() { }

    public func make() -> BaseViewController {
        return LoginViewController()
    }
}
