import UIKit

import DesignSystem
import PresentationInterface

public final class WaveTabbarFactoryMock: WaveTabbarFactory {
    public init() {}

    public func make() -> UITabBarController {
        return UITabBarController()
    }
}
