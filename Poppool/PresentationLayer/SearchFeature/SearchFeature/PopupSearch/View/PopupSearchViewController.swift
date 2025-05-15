import UIKit

import DesignSystem
import DomainInterface
import Infrastructure
import PresentationInterface
import SearchFeatureInterface

import ReactorKit
import RxCocoa
import RxSwift
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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
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

                case .category:
                    return Reactor.Action.categoryTagButtonTapped

                case .searchResultHeader:
                    return nil

                case .searchResult:
                    return Reactor.Action.searchResultItemTapped(indexPath: indexPath)

                case .searchResultEmpty:
                    return nil
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.categoryTagRemoveButtonTapped
            .map { Reactor.Action.categoryTagRemoveButtonTapped(categoryID: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        Category.valueChanged
            .map { _ in Reactor.Action.categoryChangedBySelector }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.filterStatusButtonTapped
            .map { Reactor.Action.searchResultFilterButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        Filter.valueChanged
            .map { _ in Reactor.Action.searchResultFilterChangedBySelector }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.bookmarkButtonTapped
            .map(Reactor.Action.searchResultBookmarkButtonTapped)
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
            .withUnretained(self)
            .skip(1)
            .subscribe { owner, target in
                switch target! {
                case .categorySelector:
                    @Dependency var factory: CategorySelectorFactory
                    owner.PPPresent(factory.make())

                case .filterSelector:
                    @Dependency var factory: FilterSelectorFactory
                    owner.PPPresent(factory.make())

                case .popupDetail(let popupID):
                    @Dependency var factory: DetailFactory
                    owner.navigationController?.pushViewController(
                        factory.make(popupID: popupID),
                        animated: true
                    )

                case .before:
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$searchBarText)
            .withUnretained(self)
            .subscribe { (owner, text) in owner.mainView.searchBar.searchBar.text = text }
            .disposed(by: disposeBag)

        reactor.state.distinctUntilChanged(\.recentSearchItems)
            .compactMap { $0.recentSearchItems }
            .withUnretained(self)
            .subscribe { (owner, items) in
                owner.mainView.updateSectionSnapshot(
                    at: .recentSearch,
                    with: items.map(PopupSearchView.SectionItem.recentSearchItem)
                )
            }
            .disposed(by: disposeBag)

        reactor.state.distinctUntilChanged(\.categoryItems)
            .compactMap { $0.categoryItems }
            .withUnretained(self)
            .subscribe { (owner, items) in
                owner.mainView.updateSectionSnapshot(
                    at: .category,
                    with: items.map(PopupSearchView.SectionItem.categoryItem)
                )
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$updateSearchResultDataSource)
            .withLatestFrom(reactor.state)
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.updateSearchResultSectionSnapshot(
                    with: state.searchResultItems.map(PopupSearchView.SectionItem.searchResultItem),
                    header: PopupSearchView.SectionItem.searchResultHeaderItem(state.searchResultHeader),
                    empty: state.searchResultEmpty == nil ? nil :
                    PopupSearchView.SectionItem.searchResultEmptyItem(state.searchResultEmpty!)
                )
            }
            .disposed(by: disposeBag)
    }
}
