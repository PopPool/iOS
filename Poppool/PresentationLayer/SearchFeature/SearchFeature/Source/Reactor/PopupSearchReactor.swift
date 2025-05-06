import Foundation

import DomainInterface
import Infrastructure

import ReactorKit
import RxSwift
import RxCocoa

public final class PopupSearchReactor: Reactor {

    // MARK: - Reactor
    public enum Action {
        case viewDidLoad

        case recentSearchTagButtonTapped

        case categoryTagRemoveButtonTapped(categoryID: Int)
        case categoryTagButtonTapped

        case filterOptionButtonTapped
        case searchResultItemTapped
        case loadNextPage

        case searchResultPrefetchItems(indexPathList: [IndexPath])




        case filterOptionSaveButtonTapped
        case categorySaveOrResetButtonTapped
    }

    public enum Mutation {
        case updateSearchResult(
            recentSearchItems: [TagCollectionViewCell.Input],
            categoryItems: [TagCollectionViewCell.Input],
            searchResultsItems: [PPPopupGridCollectionViewCell.Input],
            totalPagesCount: Int32,
            totalElementCount: Int64
        )

        case setupRecentSearch(items: [TagCollectionViewCell.Input])
        case setupCategory(items: [TagCollectionViewCell.Input])
        case setupSearchResult(items: [PPPopupGridCollectionViewCell.Input])
        case setupTotalPageCount(count: Int32)
        case setupTotalElementCount(count: Int64)
        case setupSearchResultHeader(item: SearchResultHeaderView.Input)

        case appendSearchResult(items: [PPPopupGridCollectionViewCell.Input])

        case present(target: PresentTarget)

        case updateCurrentPage(to: Int)
        case updateDataSource
    }

    public enum PresentTarget {
        case categorySelector
        case filterOptionSelector
    }

    public struct State {
        var recentSearchItems: [TagCollectionViewCell.Input] = []
        var categoryItems: [TagCollectionViewCell.Input] = []
        var searchResultItems: [PPPopupGridCollectionViewCell.Input] = []
        var searchResultHeader: SearchResultHeaderView.Input? = nil

        @Pulse var present: PresentTarget?
        @Pulse var updateDataSource: Void?

        fileprivate var currentPage: Int = 0
        fileprivate let paginationSize: Int = 10
        fileprivate var totalPagesCount: Int = 0
        var hasNextPage: Bool { get { currentPage < (totalPagesCount - 1) } }
        var totalElementsCount: Int = 0
    }

    // MARK: - properties
    public var initialState: State

    var disposeBag = DisposeBag()

    private let userDefaultService = UserDefaultService()
    private let popupAPIUseCase: PopUpAPIUseCase
    private let fetchKeywordBasePopupListUseCase: FetchKeywordBasePopupListUseCase

    // MARK: - init
    public init(
        popupAPIUseCase: PopUpAPIUseCase,
        fetchKeywordBasePopupListUseCase: FetchKeywordBasePopupListUseCase
    ) {
        self.popupAPIUseCase = popupAPIUseCase
        self.fetchKeywordBasePopupListUseCase = fetchKeywordBasePopupListUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return popupAPIUseCase.getSearchBottomPopUpList(
                isOpen: PopupStatus.open.requestValue,
                categories: [],
                page: 0,
                size: Int32(currentState.paginationSize),
                sort: PopupSortOption.newest.requestValue
            )
            .withUnretained(self)
            .flatMap { (owner, response) -> Observable<Mutation> in
                let searchResultItems = owner.convertResponseToSearchResultInput(response: response)

                return Observable.concat([
                    .just(.setupRecentSearch(items: owner.getRecentSearchKeywords())),
                    .just(.setupCategory(items: Category.shared.items)),
                    .just(.setupSearchResult(items: searchResultItems)),
                    .just(.setupTotalPageCount(count: response.totalPages)),
                    .just(.setupTotalElementCount(count: response.totalElements)),
                    .just(.updateDataSource)
                ])
            }

        case .loadNextPage:
            guard currentState.hasNextPage else { return .empty() }

            return popupAPIUseCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: Category.shared.getSelectedCategoryIDs(),
                page: Int32(currentState.currentPage + 1),
                size: Int32(currentState.paginationSize),
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .flatMap { (owner, response) -> Observable<Mutation> in
                let searchResultItems = owner.convertResponseToSearchResultInput(response: response)

                return Observable.concat([
                    .just(.appendSearchResult(items: searchResultItems)),
                    .just(.updateDataSource)
                ])
            }
        case .searchResultPrefetchItems(let indexPathList):
            // 마지막 섹션의 마지막 아이템
            guard let lastItemIndex = indexPathList.last?.last else { return .empty() }

            func isPrefetchable(prefetchCount: Int = 4) -> Bool {
                let isScrollToEnd = lastItemIndex > currentState.paginationSize * (currentState.currentPage + 1) - prefetchCount

                let hasNextPage = currentState.currentPage < (currentState.totalPagesCount - 1)

                return isScrollToEnd && hasNextPage
            }

            if isPrefetchable() {
                return popupAPIUseCase.getSearchBottomPopUpList(
                    isOpen: FilterOption.shared.status.requestValue,
                    categories: Category.shared.getSelectedCategoryIDs(),
                    page: Int32(currentState.currentPage + 1),
                    size: Int32(currentState.paginationSize),
                    sort: FilterOption.shared.sortOption.requestValue
                )
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    let searchResultItems = owner.convertResponseToSearchResultInput(response: response)


                    return .concat([
                        .just(.appendSearchResult(items: searchResultItems)),
                        .just(.updateCurrentPage(to: owner.currentState.currentPage + 1)),
                        .just(.updateDataSource)
                    ])
                }

            }
            return .empty()


        case .categoryTagButtonTapped:
            return .just(.present(target: .categorySelector))

        case .recentSearchTagButtonTapped: return .empty()
        case .searchResultItemTapped: return .empty()

        case .filterOptionSaveButtonTapped, .categorySaveOrResetButtonTapped:
            return popupAPIUseCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: Category.shared.getSelectedCategoryIDs(),
                page: 0,
                size: Int32(currentState.paginationSize),
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .flatMap { (owner, response) -> Observable<Mutation> in
                return .concat([
                    .just(.setupRecentSearch(items: owner.getRecentSearchKeywords())),
                    .just(.setupCategory(items: Category.shared.getCancelableCategoryItems())),
                    .just(.setupSearchResult(items: owner.convertResponseToSearchResultInput(response: response))),
                    .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: Int(response.totalElements)))),
                    .just(.setupTotalPageCount(count: response.totalPages)),
                    .just(.setupTotalElementCount(count: response.totalElements)),
                    .just(.updateDataSource)
                ])
            }

        case .categoryTagRemoveButtonTapped(let categoryID):
            Category.shared.removeItem(by: categoryID)

            return popupAPIUseCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: Category.shared.getSelectedCategoryIDs(),
                page: 0,
                size: Int32(currentState.paginationSize),
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .flatMap { (owner, response) -> Observable<Mutation> in
                let searchResultItems = owner.convertResponseToSearchResultInput(response: response)

                return Observable.concat([
                    .just(.setupCategory(items: Category.shared.items)),
                    .just(.setupSearchResult(items: searchResultItems)),
                    .just(.setupTotalPageCount(count: response.totalPages)),
                    .just(.setupTotalElementCount(count: response.totalElements)),
                    .just(.updateDataSource)
                ])
            }

        case .filterOptionButtonTapped:
            return .just(.present(target: .filterOptionSelector))
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setupRecentSearch(let items):
            newState.recentSearchItems = items

        case .setupCategory(let items):
            newState.categoryItems = items

        case .setupSearchResult(let items):
            newState.searchResultItems = items

        case .setupTotalPageCount(let count):
            newState.totalPagesCount = Int(count)

        case .setupTotalElementCount(let count):
            newState.totalElementsCount = Int(count)

        case .setupSearchResultHeader(let input):
            newState.searchResultHeader = input
            
        case .appendSearchResult(let items):
            newState.searchResultItems += items


        case .updateCurrentPage(let currentPage):
            newState.currentPage = currentPage

        case .updateDataSource:
            newState.updateDataSource = ()

        case .present(let target):
            switch target {
            case .categorySelector:
                newState.present = .categorySelector
            case .filterOptionSelector:
                newState.present = .filterOptionSelector
            }

        case .updateSearchResult(let recentSearchItems, let categoryItems, let searchResultItems, let totalPagesCount, let totalElementsCount):
            newState.recentSearchItems = recentSearchItems
            newState.categoryItems = categoryItems
            newState.searchResultItems = searchResultItems
            newState.currentPage = 0
            newState.totalPagesCount = Int(totalPagesCount)
            newState.totalElementsCount = Int(totalElementsCount)

        }

        return newState
    }
}

// MARK: - Functions
private extension PopupSearchReactor {
    func getRecentSearchKeywords() -> [TagCollectionViewCell.Input] {
        let searchKeywords = userDefaultService.fetchArray(key: "searchList") ?? []
        return searchKeywords.map { TagCollectionViewCell.Input(title: $0) }
    }

    func convertResponseToSearchResultInput(response: GetSearchBottomPopUpListResponse) -> [PPPopupGridCollectionViewCell.Input] {
        return response.popUpStoreList.map {
            PPPopupGridCollectionViewCell.Input(
                imagePath: $0.mainImageUrl,
                id: $0.id,
                category: $0.category,
                title: $0.name,
                address: $0.address,
                startDate: $0.startDate,
                endDate: $0.endDate,
                isBookmark: $0.bookmarkYn,
                isLogin: response.loginYn
            )
        }
    }

    func makeSearchResultHeaderInput(count: Int, title: String = FilterOption.shared.title) -> SearchResultHeaderView.Input {
        return SearchResultHeaderView.Input(count: count, sortedTitle: title)
    }
}
