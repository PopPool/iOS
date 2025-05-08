import UIKit

import CoordinatorKit
import DomainInterface
import DesignSystem // PPModalPresent 사용 용도
import Infrastructure

import ReactorKit
import RxSwift

public final class SearchFeatureCoordinator: BaseCoordinator {
    private let navigationController: UINavigationController
    private let disposeBag = DisposeBag()

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }

    deinit {
        print("DEBUG: \(#file) deinitialized")
    }

    public override func start() {
        let reactor = PopupSearchReactor(
            popupAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
            fetchKeywordBasePopupListUseCase: DIContainer.resolve(FetchKeywordBasePopupListUseCase.self)
        )

        let viewController = PopupSearchViewController()

        viewController.reactor = reactor
        viewController.coordinator = self
        print("DEBUG: start and coordinator is \(viewController.coordinator == nil)")

        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(viewController, animated: true)
    }

    func presentCategorySelector(
        from parentViewController: UIViewController,
        parentReactor: PopupSearchReactor
    ) {
        let reactor = CategorySelectReactor(
            fetchCategoryListUseCase: DIContainer.resolve(FetchCategoryListUseCase.self)
        )

        let viewController = CategorySelectViewController()

        viewController.reactor = reactor

        reactor.state.distinctUntilChanged(\.selectedCategoryChanged)
            .filter { $0.selectedCategoryChanged == true }
            .map { _ in PopupSearchReactor.Action.categoryChangedBySelector }
            .bind(to: parentReactor.action)
            .disposed(by: disposeBag)

        parentViewController.PPPresent(viewController)
    }

    func presentFilterSelector(
        from parentViewController: UIViewController,
        parentReactor: PopupSearchReactor
    ) {
        let reactor = FilterSelectReactor()

        let viewController = FilterSelectViewController()

        viewController.reactor = reactor

        reactor.pulse(\.$saveButtonTapped)
            .map { _ in PopupSearchReactor.Action.searchResultFilterChangedBySelector }
            .bind(to: parentReactor.action)
            .disposed(by: disposeBag)

        parentViewController.PPPresent(viewController)
    }
}
