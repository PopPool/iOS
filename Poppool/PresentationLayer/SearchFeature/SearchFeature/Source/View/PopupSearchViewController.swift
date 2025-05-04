import UIKit

import DesignSystem
import DomainInterface
import Infrastructure

import ReactorKit
import RxSwift

public final class PopupSearchViewController: BaseViewController, View {

    public typealias Reactor = PopupSearchReactor

    // MARK: - Properties
    public var disposeBag = DisposeBag()

    private let mainView = PopupSearchView()
}

// MARK: - Life Cycle
extension PopupSearchViewController {
    public override func loadView() {
        self.view = mainView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Bind
extension PopupSearchViewController {
    public func bind(reactor: Reactor) {
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self, reactor] _ in
                guard let self = self else { return }
                let sharedCategory = reactor.sourceOfTruthCategory
                let categoryReactor = SearchCategoryReactor(
                    originCategory: sharedCategory,
                    signUpAPIUseCase: DIContainer.resolve(SignUpAPIUseCase.self)
                )
                let viewController = SearchCategoryController()
                viewController.reactor = categoryReactor
                self.presentPanModal(viewController)
            })
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.updateSnapshot(
                    recentSearchItems: state.recentSearchItems
                        .map(PopupSearchView.SectionItem.recentSearchItem),
                    categoryItems: state.categoryItems
                        .map(PopupSearchView.SectionItem.categoryItem),
                    searchResultItems: state.searchResultItems
                        .map(PopupSearchView.SectionItem.searchResultItem),
                    headerInput: PopupGridCollectionHeaderView.Input(
                        count: state.searchResultItems.count,
                        sortedTitle: [state.openTitle, state.sortOptionTitle].joined(separator: "・")
                    )
                )
            }
            .disposed(by: disposeBag)
    }
}
