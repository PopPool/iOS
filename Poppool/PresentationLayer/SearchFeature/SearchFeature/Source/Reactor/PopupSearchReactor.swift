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

        case searchResultFilterButtonTapped
        case searchResultItemTapped
        case searchResultPrefetchItems(indexPathList: [IndexPath])


        case filterOptionSaveButtonTapped
        case categorySaveOrResetButtonTapped
    }

    public enum Mutation {
        case setupRecentSearch(items: [TagCollectionViewCell.Input])
        case setupCategory(items: [TagCollectionViewCell.Input])
        case setupSearchResult(items: [PPPopupGridCollectionViewCell.Input])
        case setupSearchResultHeader(item: SearchResultHeaderView.Input)
        case setupSearchResultTotalPageCount(count: Int32)

        case appendSearchResult(items: [PPPopupGridCollectionViewCell.Input])

        case present(target: PresentTarget)

        case updateCurrentPage(to: Int32)
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

        fileprivate var currentPage: Int32 = 0
        fileprivate let paginationSize: Int32 = 10
        fileprivate var totalPagesCount: Int32 = 0
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
            return fetchSearchResult()
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return Observable.concat([
                        .just(.setupRecentSearch(items: owner.makeRecentSearchItems())),
                        .just(.setupCategory(items: owner.makeCategoryItems())),
                        .just(.setupSearchResult(items: owner.makeSearchResultInputs(response: response))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: response.totalElements))),
                        .just(.setupSearchResultTotalPageCount(count: response.totalPages)),
                        .just(.updateDataSource)
                    ])
                }

        case .searchResultPrefetchItems(let indexPathList):
            guard isPrefetchable(indexPathList: indexPathList) else { return .empty() }
            return fetchSearchResult(page: currentState.currentPage + 1)
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return .concat([
                        .just(.appendSearchResult(items: owner.makeSearchResultInputs(response: response))),
                        .just(.updateCurrentPage(to: owner.currentState.currentPage + 1)),
                        .just(.updateDataSource)
                    ])
                }

        case .categoryTagButtonTapped:
            return .just(.present(target: .categorySelector))

        case .recentSearchTagButtonTapped:
            return .empty()

        case .searchResultItemTapped:
            return .empty()

        case .filterOptionSaveButtonTapped, .categorySaveOrResetButtonTapped:
            return fetchSearchResult()
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return .concat([
                        .just(.setupRecentSearch(items: owner.makeRecentSearchItems())),
                        .just(.setupCategory(items: owner.makeCategoryItems())),
                        .just(.setupSearchResult(items: owner.makeSearchResultInputs(response: response))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: response.totalElements))),
                        .just(.setupSearchResultTotalPageCount(count: response.totalPages)),
                        .just(.updateDataSource)
                    ])
            }

        case .categoryTagRemoveButtonTapped(let categoryID):
            Category.shared.removeItem(by: categoryID)
            return fetchSearchResult()
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return Observable.concat([
                        .just(.setupCategory(items: owner.makeCategoryItems())),
                        .just(.setupSearchResult(items: owner.makeSearchResultInputs(response: response))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: response.totalElements))),
                        .just(.setupSearchResultTotalPageCount(count: response.totalPages)),
                        .just(.updateCurrentPage(to: 0)),
                        .just(.updateDataSource)
                    ])
                }

        case .searchResultFilterButtonTapped:
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

        case .setupSearchResultTotalPageCount(let count):
            newState.totalPagesCount = count

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
        }

        return newState
    }
}

// MARK: Captulation Mutate
private extension PopupSearchReactor {

    func fetchSearchResult(
        isOpen: Bool = FilterOption.shared.status.requestValue,
        categoried: [Int64] = Category.shared.getSelectedCategoryIDs(),
        page: Int32 = 0,
        size: Int32 = 10,
        sort: String = FilterOption.shared.sortOption.requestValue
    ) -> Observable<GetSearchBottomPopUpListResponse> {
        return popupAPIUseCase.getSearchBottomPopUpList(
            isOpen: FilterOption.shared.status.requestValue,
            categories: Category.shared.getSelectedCategoryIDs(),
            page: 0,
            size: currentState.paginationSize,
            sort: FilterOption.shared.sortOption.requestValue
        )
    }
}

// MARK: - Make Functions
private extension PopupSearchReactor {
    func makeRecentSearchItems() -> [TagCollectionViewCell.Input] {
        let searchKeywords = userDefaultService.fetchArray(key: "searchList") ?? []
        return searchKeywords.map { TagCollectionViewCell.Input(title: $0) }
    }

    func makeCategoryItems() -> [TagCollectionViewCell.Input] {
        return Category.shared.getCancelableCategoryItems()
    }

    func makeSearchResultInputs(response: GetSearchBottomPopUpListResponse) -> [PPPopupGridCollectionViewCell.Input] {
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

    func makeSearchResultHeaderInput(count: Int64, title: String = FilterOption.shared.title) -> SearchResultHeaderView.Input {
        return SearchResultHeaderView.Input(count: Int(count), sortedTitle: title)
    }
}

// MARK: - Checking Method
private extension PopupSearchReactor {
    func isPrefetchable(prefetchCount: Int = 4, indexPathList: [IndexPath]) -> Bool {
        guard let lastItemIndex = indexPathList.last?.last else { return false }

        let isScrollToEnd = lastItemIndex > Int(currentState.paginationSize) * Int(currentState.currentPage + 1) - prefetchCount
        let hasNextPage = currentState.currentPage < (currentState.totalPagesCount - 1)

        return isScrollToEnd && hasNextPage
    }
}
