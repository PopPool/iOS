import DesignSystem
import PresentationInterface

public final class SignUpFactoryMock: SignUpFactory {

    public init() { }

    public func make(isFirstResponder: Bool = false, authrizationCode: String? = nil) -> BaseTabmanController {
        return BaseTabmanController()
    }
}
