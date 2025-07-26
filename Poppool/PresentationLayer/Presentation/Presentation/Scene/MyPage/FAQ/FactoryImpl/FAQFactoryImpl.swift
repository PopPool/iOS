import DesignSystem
import PresentationInterface

public final class FAQFactoryImpl: FAQFactory {
    public init() { }

    public func make() -> BaseViewController {
        let viewController = FAQController()
        viewController.reactor = FAQReactor()

        return viewController
    }
}
