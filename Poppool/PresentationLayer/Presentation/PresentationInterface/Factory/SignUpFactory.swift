import DesignSystem

public protocol SignUpFactory {
    func make(isFirstResponder: Bool, authrizationCode: String?) -> BaseTabmanController
}
