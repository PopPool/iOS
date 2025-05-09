import DesignSystem
import DomainInterface
import Infrastructure
import SearchFeatureInterface

public final class PopupSearchFactoryImpl: PopupSearchFactory {
    public init() { }

    public func make() -> BaseViewController {
        let viewController = PopupSearchViewController()

        viewController.reactor = PopupSearchReactor(
            popupAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
            fetchKeywordBasePopupListUseCase: DIContainer.resolve(FetchKeywordBasePopupListUseCase.self)
        )

        return viewController
    }
}
