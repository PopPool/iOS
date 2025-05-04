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
    }

    public enum Mutation {
        case setInitialState(
            recentSearch: [TagCollectionViewCell.Input],
            categoryItems: [TagCollectionViewCell.Input],
            results: [PPPopupGridCollectionViewCell.Input]
        )

        case updateResult(
            recentSearch: [TagCollectionViewCell.Input],
            categoryItems: [TagCollectionViewCell.Input],
            results: [PPPopupGridCollectionViewCell.Input]
        )
    }

    public struct State {
        var recentSearchItems: [TagCollectionViewCell.Input] = []
        var categoryItems: [TagCollectionViewCell.Input] = Category.shared.items
        var searchResultItems: [PPPopupGridCollectionViewCell.Input] = []
        var openTitle: String = PopupStatus.open.title
        var sortOptionTitle: String = PopupSortOption.newest.title
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
                size: 10,
                sort: PopupSortOption.newest.requestValue
            )
            .withUnretained(self)
            .map { owner, response in
                return .setInitialState(
                    recentSearch: owner.getRecentSearchKeywords(),
                    categoryItems: Category.shared.items,
                    results: owner.convertResponseToSearchResultInput(response: response)
                )
            }

        case .filterOptionSaveButtonTapped:
            return useCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: [],
                page: 0,
                size: 10,
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .map { (owner, response) in
                return .updateResult(
                    recentSearch: owner.getRecentSearchKeywords(),
                    categoryItems: Category.shared.items,
                    results: owner.convertResponseToSearchResultInput(response: response)
                )

            }

        case .categorySaveOrResetButtonTapped:
            return useCase.getSearchBottomPopUpList(
                isOpen: FilterOption.shared.status.requestValue,
                categories: Category.shared.getSelectedCategoryIDs(),
                page: 0,
                size: 10,
                sort: FilterOption.shared.sortOption.requestValue
            )
            .withUnretained(self)
            .map { (owner, response) in
                return .updateResult(
                    recentSearch: owner.getRecentSearchKeywords(),
                    categoryItems: Category.shared.items,
                    results: owner.convertResponseToSearchResultInput(response: response)
                )
            }
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setInitialState(let recentSearchItems, let categoryItems, let searchResultItems):
            newState.recentSearchItems = recentSearchItems
            newState.categoryItems = categoryItems
            newState.searchResultItems = searchResultItems

        case .updateResult(let recentSearchItems, let categoryItems, let searchResultItems):
            newState.recentSearchItems = recentSearchItems
            newState.categoryItems = categoryItems
            newState.searchResultItems = searchResultItems
            newState.openTitle = FilterOption.shared.status.title
            newState.sortOptionTitle = FilterOption.shared.sortOption.title
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
