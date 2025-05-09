import DesignSystem
import Infrastructure
import SearchFeatureInterface

public final class FilterSelectorFactoryImpl: FilterSelectorFactory {
    public init() { }
    
    public func make() -> BaseViewController & PPModalPresentable {
        let reactor = FilterSelectReactor()
        let viewController = FilterSelectViewController()
        viewController.reactor = reactor

        return viewController
    }
}
