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
            category: [TagCollectionViewCell.Input],
            results: [PPPopupGridCollectionViewCell.Input]
        )
    }

    public struct State {
        var recentSearchItems: [TagCollectionViewCell.Input] = []
        var categoryItems: [TagCollectionViewCell.Input] = []
        var searchResultItems: [PPPopupGridCollectionViewCell.Input] = []
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
            print("ViewDidLoad")
            return useCase.getSearchBottomPopUpList(
                isOpen: true,
                categories: [],
                page: 0,
                size: 10,
                sort: "NEWEST"
            )
            .withUnretained(self)
            .map { owner, response in
                return .setInitialState(
                    recentSearch: [],
                    category: [],
                    results: owner.convertResponseToSearchResultInput(response: response))
            }
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setInitialState(recentSearch, category, results):
            newState.recentSearchItems = recentSearch
            newState.categoryItems = category
            newState.searchResultItems = results
        }
        return newState
    }
}

// MARK: - Functions
private extension PopupSearchReactor {
    func getRecentSearchKeywords() -> [String] {
        return userDefaultService.fetchArray(key: "searchList") ?? []
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
