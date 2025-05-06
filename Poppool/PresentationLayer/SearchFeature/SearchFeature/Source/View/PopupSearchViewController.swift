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

        mainView.collectionView.rx.prefetchItems
            .throttle(.milliseconds(100), latest: false , scheduler: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { (owner, indexPaths) in
                let sections = owner.mainView.getSectionsFromDataSource()

                guard let searchResultSectionIndex = sections.firstIndex(where: { section in
                    switch section {
                    case .searchResult: return true
                    default: return false
                    }
                }) else { return }

                /// prefetch를 하기까지 남은 아이템의 갯수
                let prefetchCount = 2

                let itemCount = owner.mainView.collectionView.numberOfItems(inSection: searchResultSectionIndex)

                guard itemCount > prefetchCount else { return }

                /// 보여줄 아이템이 prefetchCount만큼 남았을때 가까운 상태라고 확인
                let isNearBottom = indexPaths.contains {
                    $0.section == searchResultSectionIndex &&
                    $0.item >= owner.mainView.collectionView.numberOfItems(inSection: $0.section) - prefetchCount
                }

                if isNearBottom { owner.reactor?.action.onNext(.loadNextPage) }
            }
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
                    headerInput: SearchResultHeaderView.Input(
                        count: state.totalElementsCount,
                        sortedTitle: [state.openTitle, state.sortOptionTitle].joined(separator: "・")
                    )
                )
            }
            .disposed(by: disposeBag)
    }

    private func bindAction(reactor: Reactor) {
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.collectionView.rx.itemSelected
            .compactMap { indexPath in
                let sections = self.mainView.getSectionsFromDataSource()
                guard indexPath.section < sections.count else { return nil }

                switch sections[indexPath.section] {
                case .recentSearch:
                    return Reactor.Action.recentSearchTagButtonTapped

                case .category:
                    return Reactor.Action.categoryTagButtonTapped

                case .searchResult:
                    return Reactor.Action.searchResultItemTapped
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.categoryTagRemoveButtonTapped
            .map { Reactor.Action.categoryTagRemoveButtonTapped(categoryID: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.filterOptionButtonTapped
            .map { Reactor.Action.filterOptionButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindState(reactor: Reactor) {
        reactor.pulse(\.$presentTarget)
            .withUnretained(self)
            .subscribe { owner, target in
                switch target {
                case .categorySelector:
                    let categoryReactor = CategorySelectReactor(
                        fetchCategoryListUseCase: DIContainer.resolve(FetchCategoryListUseCase.self)
                    )
                    let viewController = CategorySelectViewController()
                    viewController.reactor = categoryReactor

                    // 완료 후 다시 Reactor로 Action 보내기
                    categoryReactor.state
                        .filter { $0.isSaveOrResetButtonTapped }
                        .map { _ in Reactor.Action.categorySaveOrResetButtonTapped }
                        .bind(to: owner.reactor!.action)
                        .disposed(by: owner.disposeBag)

                    owner.presentPanModal(viewController)

                case .filterOptionSelector:
                    let viewController = FilterOptionSelectViewController()
                    viewController.reactor = FilterOptionSelectReactor()

                    viewController.reactor?.state
                        .filter { $0.isSaveButtonTapped == true }
                        .map { _ in Reactor.Action.filterOptionSaveButtonTapped }
                        .bind(to: reactor.action)
                        .disposed(by: owner.disposeBag)

                    owner.presentPanModal(viewController)

                default: break
                }
            }
            .disposed(by: disposeBag)
    }
}
