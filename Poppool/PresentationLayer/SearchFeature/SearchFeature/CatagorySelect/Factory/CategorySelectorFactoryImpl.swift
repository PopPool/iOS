import DesignSystem
import DomainInterface
import Infrastructure
import SearchFeatureInterface

public final class CategorySelectorFactoryImpl: CategorySelectorFactory {
    public init() { }

    public func make() -> BaseViewController & PPModalPresentable {
        let reactor = CategorySelectReactor(
            fetchCategoryListUseCase: DIContainer.resolve(FetchCategoryListUseCase.self)
        )
        let viewController = CategorySelectViewController()

        viewController.reactor = reactor

        return viewController
    }
}
