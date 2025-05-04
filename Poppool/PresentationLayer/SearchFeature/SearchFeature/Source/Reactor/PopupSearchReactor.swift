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
    }

    public enum Mutation {
        case setInitialState(
            recentSearch: [TagCollectionViewCell.Input],
            categoryItems: [TagCollectionViewCell.Input],
            results: [PPPopupGridCollectionViewCell.Input]
        )
    }

    public struct State {
        var recentSearchItems: [TagCollectionViewCell.Input] = []
        var categoryItems: [TagCollectionViewCell.Input] = []
        var searchResultItems: [PPPopupGridCollectionViewCell.Input] = []
        var openTitle: String = PopupStatus.open.title
        var sortOptionTitle: String = PopupSortOption.newest.title
    }

    // MARK: - properties
    public var initialState: State

    var disposeBag = DisposeBag()

    private let userDefaultService = UserDefaultService()
    private let useCase: PopUpAPIUseCase

    public let sourceOfTruthCategory: Category = Category(
        items: [TagCollectionViewCell.Input(title: "카테고리", isSelected: false, isCancelable: false)]
    )

    // MARK: - init
    public init(useCase: PopUpAPIUseCase) {
        self.useCase = useCase
        self.initialState = State(categoryItems: self.sourceOfTruthCategory.items)
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
                    categoryItems: owner.sourceOfTruthCategory.items,
                    results: owner.convertResponseToSearchResultInput(response: response)
                )
            }
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setInitialState(recentSearchItems, categoryItems, searchResultItems):
            newState.recentSearchItems = recentSearchItems
            newState.categoryItems = categoryItems
            newState.searchResultItems = searchResultItems
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
