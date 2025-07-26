import UIKit

import PresentationInterface

public final class WaveTabbarFactoryImpl: WaveTabbarFactory {
    public init() { }

    public func make() -> UITabBarController {
        return WaveTabBarController()
    }
}
