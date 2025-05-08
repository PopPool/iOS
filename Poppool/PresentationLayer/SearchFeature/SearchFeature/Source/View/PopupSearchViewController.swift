import UIKit

import DesignSystem
import DomainInterface
import Infrastructure

import ReactorKit
import RxSwift
import RxCocoa
import Then

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

    public override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 20
        }

        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

// MARK: - Bind
extension PopupSearchViewController {
    public func bind(reactor: Reactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }

    private func bindAction(reactor: Reactor) {
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.tapGestureRecognizer.rx.event
            .map { _ in Reactor.Action.searchBarEndEditing }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.searchBar.searchBar.searchTextField.rx.controlEvent([.editingDidBegin, .editingChanged])
            .withLatestFrom(mainView.searchBar.searchBar.searchTextField.rx.text.orEmpty)
            .map(Reactor.Action.searchBarEditing)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.searchBar.searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(mainView.searchBar.searchBar.searchTextField.rx.text.orEmpty)
            .map(Reactor.Action.searchBarExitEditing)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.searchBar.clearButton.rx.tap
            .map { Reactor.Action.searchBarClearButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.searchBar.cancelButton.rx.tap
            .map { _ in Reactor.Action.searchBarCancelButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.recentSearchTagRemoveButtonTapped
            .map(Reactor.Action.recentSearchTagRemoveButtonTapped)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.recentSearchTagRemoveAllButtonTapped
            .map { Reactor.Action.recentSearchTagRemoveAllButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.collectionView.rx.itemSelected
            .compactMap { indexPath in
                let sections = self.mainView.getSectionsFromDataSource()
                guard indexPath.section < sections.count else { return nil }

                switch sections[indexPath.section] {
                case .recentSearch:
                    return Reactor.Action.recentSearchTagButtonTapped(indexPath: indexPath)
                case .category: return Reactor.Action.categoryTagButtonTapped
                case .searchResult: return Reactor.Action.searchResultItemTapped
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.categoryTagRemoveButtonTapped
            .map { Reactor.Action.categoryTagRemoveButtonTapped(categoryID: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.filterStatusButtonTapped
            .map { Reactor.Action.searchResultFilterButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.collectionView.rx.prefetchItems
            .throttle(.milliseconds(100), latest: false, scheduler: MainScheduler.asyncInstance)
            .map(Reactor.Action.searchResultPrefetchItems)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindState(reactor: Reactor) {
        reactor.pulse(\.$endEditing)
            .withUnretained(self)
            .subscribe { (owner, _) in owner.mainView.endEditing(true) }
            .disposed(by: disposeBag)

        reactor.pulse(\.$clearButtonIsHidden)
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe { (owner, state) in owner.mainView.searchBar.clearButton.isHidden = state }
            .disposed(by: disposeBag)

        reactor.pulse(\.$present)
            .debug("DEBUG: present")
            .withUnretained(self)
            .subscribe { owner, target in
                switch target {
                case .categorySelector:
                    let viewController = CategorySelectViewController()
                    viewController.reactor = CategorySelectReactor(
                        fetchCategoryListUseCase: DIContainer.resolve(FetchCategoryListUseCase.self)
                    )

                    viewController.reactor?.state.distinctUntilChanged(\.selectedCategoryChanged)
                        .filter { $0.selectedCategoryChanged == true }
                        .map { _ in Reactor.Action.categoryChangedBySelector }
                        .bind(to: reactor.action)
                        .disposed(by: owner.disposeBag)

                    owner.PPPresent(viewController)

                case .filterSelector:
                    let viewController = FilterSelectViewController()
                    viewController.reactor = FilterSelectReactor()

                    viewController.reactor?.pulse(\.$saveButtonTapped)
                        .map { _ in Reactor.Action.searchResultFilterChangedBySelector }
                        .bind(to: reactor.action)
                        .disposed(by: owner.disposeBag)

                    owner.PPPresent(viewController)

                default: break
                }
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$searchBarText)
            .withUnretained(self)
            .subscribe { (owner, text) in owner.mainView.searchBar.searchBar.text = text }
            .disposed(by: disposeBag)

        reactor.pulse(\.$updateDataSource)
            .withLatestFrom(reactor.state)
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.updateSnapshot(
                    recentSearchItems: state.recentSearchItems.map(PopupSearchView.SectionItem.recentSearchItem),
                    categoryItems: state.categoryItems.map(PopupSearchView.SectionItem.categoryItem),
                    searchResultItems: state.searchResultItems.map(PopupSearchView.SectionItem.searchResultItem),
                    headerInput: state.searchResultHeader,
                    searchResultEmpty: state.searchResultEmptyCase
                )
            }
            .disposed(by: disposeBag)
    }
}
