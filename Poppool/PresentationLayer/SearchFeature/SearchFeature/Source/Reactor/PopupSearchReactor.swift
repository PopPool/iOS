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

        case loadNextPage


        case filterOptionSaveButtonTapped
        case categorySaveOrResetButtonTapped
        case categoryCancelButtonTapped(categoryID: Int)
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

        case appendSearchResult(items: [PPPopupGridCollectionViewCell.Input])
    }

    public struct State {
        var recentSearchItems: [TagCollectionViewCell.Input] = []
        var categoryItems: [TagCollectionViewCell.Input] = []
        var searchResultItems: [PPPopupGridCollectionViewCell.Input] = []
        var openTitle: String = PopupStatus.open.title
        var sortOptionTitle: String = PopupSortOption.newest.title

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
                    .just(.setupTotalElementCount(count: response.totalElements))
                ])
            }

        case .loadNextPage:
            guard currentState.hasNextPage else {
                return .empty() }

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
                    .just(.appendSearchResult(items: searchResultItems))
                ])
            }

        case .filterOptionSaveButtonTapped, .categorySaveOrResetButtonTapped:
            return popupAPIUseCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: Category.shared.getSelectedCategoryIDs(),
                page: 0,
                size: Int32(currentState.paginationSize),
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .map { (owner, response) in
                return .updateSearchResult(
                    recentSearchItems: owner.getRecentSearchKeywords(),
                    categoryItems: Category.shared.getCancelableCategoryItems(),
                    searchResultsItems: owner.convertResponseToSearchResultInput(response: response),
                    totalPagesCount: response.totalPages,
                    totalElementCount: response.totalElements
                )
            }

        case .categoryCancelButtonTapped(let categoryID):
            Category.shared.removeItem(by: categoryID)

            return popupAPIUseCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: Category.shared.getSelectedCategoryIDs(),
                page: 0,
                size: Int32(currentState.paginationSize),
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .map { (owner, response) in
                return .updateSearchResult(
                    recentSearchItems: owner.getRecentSearchKeywords(),
                    categoryItems: Category.shared.getCancelableCategoryItems(),
                    searchResultsItems: owner.convertResponseToSearchResultInput(response: response),
                    totalPagesCount: response.totalPages,
                    totalElementCount: response.totalElements
                )

            }
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


            
        case .updateSearchResult(let recentSearchItems, let categoryItems, let searchResultItems, let totalPagesCount, let totalElementsCount):
            newState.recentSearchItems = recentSearchItems
            newState.categoryItems = categoryItems
            newState.searchResultItems = searchResultItems
            newState.openTitle = FilterOption.shared.status.title
            newState.sortOptionTitle = FilterOption.shared.sortOption.title
            newState.currentPage = 0
            newState.totalPagesCount = Int(totalPagesCount)
            newState.totalElementsCount = Int(totalElementsCount)

        case .appendSearchResult(let items):
            newState.searchResultItems += items
            newState.currentPage += 1
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
}
