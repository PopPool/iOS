import UIKit

import DesignSystem
import DomainInterface
import Infrastructure

import ReactorKit
import RxSwift
import RxCocoa

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
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }

    private func bindAction(reactor: Reactor) {
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.tapGestureRecognizer.rx.event
            .map { _ in Reactor.Action.textFieldEndEditing }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.searchBar.clearButton.rx.tap
            .map { Reactor.Action.clearButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.searchBar.searchBar.searchTextField.rx.controlEvent([.editingDidBegin, .editingChanged])
            .withLatestFrom(mainView.searchBar.searchBar.searchTextField.rx.text.orEmpty)
            .map(Reactor.Action.textFieldEditing)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.searchBar.searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(mainView.searchBar.searchBar.searchTextField.rx.text.orEmpty)
            .map(Reactor.Action.textFieldExitEditing)
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
                case .recentSearch: return Reactor.Action.recentSearchTagButtonTapped
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

        reactor.pulse(\.$clearButton)
            .withUnretained(self)
            .subscribe { (owner, state) in owner.mainView.searchBar.clearButton.isHidden = state?.value ?? true }
            .disposed(by: disposeBag)

        reactor.pulse(\.$clearButtonTapped)
            .withUnretained(self)
            .subscribe { (owner, _) in owner.mainView.searchBar.searchBar.searchTextField.text = nil }
            .disposed(by: disposeBag)

        reactor.pulse(\.$present)
            .withUnretained(self)
            .subscribe { owner, target in
                switch target {
                case .categorySelector:
                    let categoryReactor = CategorySelectReactor(
                        fetchCategoryListUseCase: DIContainer.resolve(FetchCategoryListUseCase.self)
                    )
                    let viewController = CategorySelectViewController()
                    viewController.reactor = categoryReactor

                    #warning("pulse에서 bind하는 구조...? 개선 가능하려나")
                    categoryReactor.state
                        .filter { $0.isSaveOrResetButtonTapped }
                        .map { _ in Reactor.Action.categorySaveOrResetButtonTapped }
                        .bind(to: owner.reactor!.action)
                        .disposed(by: owner.disposeBag)

                    owner.presentPanModal(viewController)

                case .filterSelector:
                    let viewController = FilterSelectViewController()
                    viewController.reactor = FilterSelectReactor()

                    viewController.reactor?.state
                        .filter { $0.isSaveButtonTapped == true }
                        .map { _ in Reactor.Action.filterSaveButtonTapped }
                        .bind(to: reactor.action)
                        .disposed(by: owner.disposeBag)

                    owner.presentPanModal(viewController)

                default: break
                }
            }
            .disposed(by: disposeBag)


        reactor.pulse(\.$updateDataSource)
            .withLatestFrom(reactor.state)
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.updateSnapshot(
                    recentSearchItems: state.recentSearchItems.map(PopupSearchView.SectionItem.recentSearchItem),
                    categoryItems: state.categoryItems.map(PopupSearchView.SectionItem.categoryItem),
                    searchResultItems: state.searchResultItems.map(PopupSearchView.SectionItem.searchResultItem),
                    headerInput: state.searchResultHeader
                )
            }
            .disposed(by: disposeBag)
    }
}
