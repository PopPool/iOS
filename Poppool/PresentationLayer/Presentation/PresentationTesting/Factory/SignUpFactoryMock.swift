import DesignSystem
import PresentationInterface

public final class SignUpFactoryMock: SignUpFactory {

    public init() { }

    public func make(isFirstResponder: Bool = false, authorizationCode: String? = nil) -> BaseTabmanController {
        return BaseTabmanController()
    }
}
