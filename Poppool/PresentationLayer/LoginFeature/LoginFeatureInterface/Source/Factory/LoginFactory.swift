import UIKit

import DesignSystem

public enum LoginSceneType {
    case main
    case sub
}

public protocol LoginFactory {
    func make(
        _ type: LoginSceneType,
        text: String
    ) -> BaseViewController
}
