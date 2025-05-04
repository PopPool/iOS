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
        case filterOptionSaveButtonTapped
        case categorySaveOrResetButtonTapped
        case viewAllVisibleItems
    }

    public enum Mutation {
        case setInitialState(
            recentSearchItems: [TagCollectionViewCell.Input],
            categoryItems: [TagCollectionViewCell.Input],
            searchResultsItems: [PPPopupGridCollectionViewCell.Input],
            totalPages: Int32
        )

        case updateSearchResult(
            recentSearchItems: [TagCollectionViewCell.Input],
            categoryItems: [TagCollectionViewCell.Input],
            searchResultsItems: [PPPopupGridCollectionViewCell.Input],
            totalPage: Int32
        )

        case fetchNextPage(searchResultsItems: [PPPopupGridCollectionViewCell.Input])
    }

    public struct State {
        var recentSearchItems: [TagCollectionViewCell.Input] = []
        var categoryItems: [TagCollectionViewCell.Input] = Category.shared.items
        var searchResultItems: [PPPopupGridCollectionViewCell.Input] = []
        var openTitle: String = PopupStatus.open.title
        var sortOptionTitle: String = PopupSortOption.newest.title

        fileprivate var currentPage: Int32 = 0
        fileprivate let paginationSize: Int32 = 10
        fileprivate var totalPages: Int32 = 0
        var hasNextPage: Bool { get { currentPage < (totalPages - 1) } }
    }

    // MARK: - properties
    public var initialState: State

    var disposeBag = DisposeBag()

    private let userDefaultService = UserDefaultService()
    private let useCase: PopUpAPIUseCase

    // MARK: - init
    public init(useCase: PopUpAPIUseCase) {
        self.useCase = useCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return useCase.getSearchBottomPopUpList(
                isOpen: PopupStatus.open.requestValue,
                categories: [],
                page: 0,
                size: currentState.paginationSize,
                sort: PopupSortOption.newest.requestValue
            )
            .withUnretained(self)
            .map { owner, response in
                return .setInitialState(
                    recentSearchItems: owner.getRecentSearchKeywords(),
                    categoryItems: Category.shared.items,
                    searchResultsItems: owner.convertResponseToSearchResultInput(response: response),
                    totalPages: response.totalPages
                )
            }

        case .filterOptionSaveButtonTapped, .categorySaveOrResetButtonTapped:
            return useCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: Category.shared.getSelectedCategoryIDs(),
                page: 0,
                size: currentState.paginationSize,
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .map { (owner, response) in
                return .updateSearchResult(
                    recentSearchItems: owner.getRecentSearchKeywords(),
                    categoryItems: Category.shared.items,
                    searchResultsItems: owner.convertResponseToSearchResultInput(response: response),
                    totalPage: response.totalPages
                )

            }

        case .viewAllVisibleItems:
            guard currentState.hasNextPage else { return .empty() }

            return useCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: Category.shared.getSelectedCategoryIDs(),
                page: currentState.currentPage + 1,
                size: currentState.paginationSize,
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .map { (owner, response) in
                return .fetchNextPage(searchResultsItems: owner.convertResponseToSearchResultInput(response: response))
            }
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setInitialState(let recentSearchItems, let categoryItems, let searchResultItems, let totalPages):
            newState.recentSearchItems = recentSearchItems
            newState.categoryItems = categoryItems
            newState.searchResultItems = searchResultItems
            newState.totalPages = totalPages


        case .updateSearchResult(let recentSearchItems, let categoryItems, let searchResultItems, let totalPages):
            newState.recentSearchItems = recentSearchItems
            newState.categoryItems = categoryItems
            newState.searchResultItems = searchResultItems
            newState.openTitle = FilterOption.shared.status.title
            newState.sortOptionTitle = FilterOption.shared.sortOption.title
            newState.currentPage = 0
            newState.totalPages = totalPages

        case .fetchNextPage(let searchResultItems):
            newState.searchResultItems += searchResultItems
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
