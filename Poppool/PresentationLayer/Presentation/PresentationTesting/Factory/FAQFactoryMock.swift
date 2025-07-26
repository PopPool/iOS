import DesignSystem
import PresentationInterface

public final class FAQFactoryMock: FAQFactory {

    public init() { }

    public func make() -> BaseViewController {
        return BaseViewController()
    }
}
