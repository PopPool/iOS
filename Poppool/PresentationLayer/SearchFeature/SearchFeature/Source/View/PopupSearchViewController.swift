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
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.collectionView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { (owner, indexPath) in
                let sections = owner.mainView.getSectionsFromDataSource()
                guard indexPath.section < sections.count else { return }

                switch sections[indexPath.section] {
                case .recentSearch: return
                case .category:


                    let categoryReactor = CategorySelectReactor(
                        fetchCategoryListUseCase: DIContainer.resolve(FetchCategoryListUseCase.self)
                    )
                    let viewController = CategorySelectViewController()
                    viewController.reactor = categoryReactor

                    viewController.reactor?.state
                        .filter { $0.isSaveOrResetButtonTapped == true }
                        .map { _ in Reactor.Action.categorySaveOrResetButtonTapped }
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)

                    self.presentPanModal(viewController)
                case .searchResult:
                    // MARK: 디테일 화면으로 이동하기
                    print("SECTION DEBUG:", sections[indexPath.section])
                }
            })
            .disposed(by: disposeBag)

        /// CollectionView에 등록된 Header중 searchResult의 헤더를 찾아서 내부에 있는 button에 접근하기 위한 Rx 바인딩
        mainView.collectionView.rx.willDisplaySupplementaryView
            .filter { $0.elementKind == PopupSearchView.SectionHeaderKind.searchResult.rawValue }
            .compactMap { $0.supplementaryView as? PopupGridCollectionHeaderView }
            .withUnretained(self)
            .subscribe(onNext: { (owner, headerView) in
                headerView.filterOptionButton.rx.tap
                    .subscribe { _ in
                        let viewController = FilterOptionSelectViewController()
                        viewController.reactor = FilterOptionSelectReactor()

                        viewController.reactor?.state
                            .filter { $0.isSaveButtonTapped == true }
                            .map { _ in Reactor.Action.filterOptionSaveButtonTapped }
                            .bind(to: reactor.action)
                            .disposed(by: owner.disposeBag)

                        owner.presentPanModal(viewController)
                    }
                    .disposed(by: owner.disposeBag)
            })
            .disposed(by: disposeBag)


        mainView.collectionView.rx.prefetchItems
            .throttle(.seconds(1), latest: false , scheduler: MainScheduler.instance)
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

                if isNearBottom { owner.reactor?.action.onNext(.viewAllVisibleItems) }
            }
            .disposed(by: disposeBag)

        mainView.canceledCategoryID
            .map { Reactor.Action.categoryCancelButtonTapped(categoryID: $0) }
            .bind(to: reactor.action)
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
                        count: state.totalElementsCount,
                        sortedTitle: [state.openTitle, state.sortOptionTitle].joined(separator: "・")
                    )
                )
            }
            .disposed(by: disposeBag)
    }
}
