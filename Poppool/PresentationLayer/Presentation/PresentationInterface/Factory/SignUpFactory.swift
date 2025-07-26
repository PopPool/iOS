import DesignSystem

public protocol SignUpFactory {
    func make(isFirstResponder: Bool, authorizationCode: String?) -> BaseTabmanController
}
