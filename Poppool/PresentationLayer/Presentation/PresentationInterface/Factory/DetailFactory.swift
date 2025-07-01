import DesignSystem

public protocol DetailFactory {
    func make(popupID: Int) -> BaseViewController
}
