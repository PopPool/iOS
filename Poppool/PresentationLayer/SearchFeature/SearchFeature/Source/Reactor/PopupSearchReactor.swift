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

        case searchBarEditing(text: String)
        case searchBarExitEditing(text: String)
        case searchBarEndEditing
        case searchBarClearButtonTapped
        case searchBarCancelButtonTapped

        case recentSearchTagButtonTapped
        case recentSearchTagRemoveAllButtonTapped

        case categoryTagRemoveButtonTapped(categoryID: Int)
        case categoryTagButtonTapped

        case searchResultFilterButtonTapped
        case searchResultItemTapped
        case searchResultPrefetchItems(indexPathList: [IndexPath])

        case filterSaveButtonTapped
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
        case clearButton(state: ClearButtonState)
        case clearTextField
        case endEditing

        case updateCurrentPage(to: Int32)
        case updateSearching(to: Bool)
        case updateDataSource
    }

    public enum PresentTarget {
        case categorySelector
        case filterSelector
    }

    public enum ClearButtonState {
        var value: Bool {
            switch self {
            case .visible: return false
            case .hidden: return true
            }
        }
        
        case visible
        case hidden
    }

    public struct State {
        var recentSearchItems: [TagCollectionViewCell.Input] = []
        var categoryItems: [TagCollectionViewCell.Input] = []
        var searchResultItems: [PPPopupGridCollectionViewCell.Input] = []
        var searchResultHeader: SearchResultHeaderView.Input? = nil

        @Pulse var present: PresentTarget?
        @Pulse var clearButton: ClearButtonState?
        @Pulse var clearButtonTapped: Void?
        @Pulse var endEditing: Void?
        @Pulse var updateDataSource: Void?

        fileprivate var isSearching: Bool = false
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
                        .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popUpStoreList, response.loginYn))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: response.totalElements))),
                        .just(.setupSearchResultTotalPageCount(count: response.totalPages)),
                        .just(.updateCurrentPage(to: 0)),
                        .just(.updateDataSource)
                    ])
                }

        case .searchBarEditing(let text):
            return .just(.clearButton(state: text.isEmpty ? .hidden : .visible))

        case .searchBarExitEditing(let text):
            return fetchSearchResult(keyword: text)
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return Observable.concat([
                        .just(.setupRecentSearch(items: [])),
                        .just(.setupCategory(items: [])),
                        .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popupStoreList, response.loginYn))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: 0))), // FIXME: API에 해당 결과값이 아직 없음
                        .just(.setupSearchResultTotalPageCount(count: 0)),  // FIXME: API에 해당 결과값이 아직 없음
                        .just(.updateCurrentPage(to: 0)),
                        .just(.updateSearching(to: true)),
                        .just(.clearButton(state: .hidden)),
                        .just(.endEditing),
                        .just(.updateDataSource)
                    ])
                }

        case .searchBarEndEditing:
            return .concat([
                .just(.clearButton(state: .hidden)),
                .just(.endEditing)
            ])

        case .searchBarCancelButtonTapped:
            if currentState.isSearching {
                return fetchSearchResult()
                    .withUnretained(self)
                    .flatMap { (owner, response) -> Observable<Mutation> in
                        return Observable.concat([
                            .just(.setupRecentSearch(items: owner.makeRecentSearchItems())),
                            .just(.setupCategory(items: owner.makeCategoryItems())),
                            .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popUpStoreList, response.loginYn))),
                            .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: response.totalElements))),
                            .just(.setupSearchResultTotalPageCount(count: response.totalPages)),
                            .just(.updateCurrentPage(to: 0)),
                            .just(.updateSearching(to: false)),
                            .just(.clearTextField),
                            .just(.updateDataSource)
                        ])
                    }
            }
            else { return .empty() }    // TODO: 이전 화면으로 보내기


        case .recentSearchTagRemoveAllButtonTapped:
            self.removeAllRecentSearchItems()
            return .concat([
                .just(.setupRecentSearch(items: self.makeRecentSearchItems())),
                .just(.updateDataSource)
            ])


        case .searchResultPrefetchItems(let indexPathList):
            guard isPrefetchable(indexPathList: indexPathList) else { return .empty() }
            return fetchSearchResult(page: currentState.currentPage + 1)
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return .concat([
                        .just(.appendSearchResult(items: owner.makeSearchResultItems(response.popUpStoreList, response.loginYn))),
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

        case .filterSaveButtonTapped, .categorySaveOrResetButtonTapped:
            return fetchSearchResult()
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return .concat([
                        .just(.setupRecentSearch(items: owner.makeRecentSearchItems())),
                        .just(.setupCategory(items: owner.makeCategoryItems())),
                        .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popUpStoreList, response.loginYn))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: response.totalElements))),
                        .just(.setupSearchResultTotalPageCount(count: response.totalPages)),
                        .just(.updateCurrentPage(to: 0)),
                        .just(.updateDataSource)
                    ])
            }

        case .searchBarClearButtonTapped:
            return Observable.concat([
                .just(.clearButton(state: .hidden)),
                .just(.clearTextField)
            ])

        case .categoryTagRemoveButtonTapped(let categoryID):
            self.removeCategoryItem(by: categoryID)
            return fetchSearchResult()
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return Observable.concat([
                        .just(.setupCategory(items: owner.makeCategoryItems())),
                        .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popUpStoreList, response.loginYn))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: response.totalElements))),
                        .just(.setupSearchResultTotalPageCount(count: response.totalPages)),
                        .just(.updateCurrentPage(to: 0)),
                        .just(.updateDataSource)
                    ])
                }

        case .searchResultFilterButtonTapped:
            return .just(.present(target: .filterSelector))
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

        case .updateSearching(let isSearching):
            newState.isSearching = isSearching

        case .updateDataSource:
            newState.updateDataSource = ()

        case .present(let target):
            newState.present = target

        case .clearButton(let state):
            newState.clearButton = state

        case .clearTextField:
            newState.clearButtonTapped = ()

        case .endEditing:
            newState.endEditing = ()
        }

        return newState
    }
}

// MARK: Captulation Mutate
private extension PopupSearchReactor {

    func fetchSearchResult(
        isOpen: Bool = Filter.shared.status.requestValue,
        categories: [Int64] = Category.shared.getSelectedCategoryIDs(),
        page: Int32 = 0,
        size: Int32 = 10,
        sort: String = Filter.shared.sort.requestValue
    ) -> Observable<GetSearchBottomPopUpListResponse> {
        return popupAPIUseCase.getSearchBottomPopUpList(
            isOpen: isOpen,
            categories: categories,
            page: page,
            size: size,
            sort: sort
        )
    }

    func fetchSearchResult(keyword: String) -> Observable<KeywordBasePopupStoreListResponse> {
        fetchKeywordBasePopupListUseCase.execute(keyword: keyword)
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

    func makeSearchResultItems(_ popupStoreList: [PopUpStoreResponse], _ loginYn: Bool) -> [PPPopupGridCollectionViewCell.Input] {
        return popupStoreList.map {
            PPPopupGridCollectionViewCell.Input(
                imagePath: $0.mainImageUrl,
                id: $0.id,
                category: $0.category,
                title: $0.name,
                address: $0.address,
                startDate: $0.startDate,
                endDate: $0.endDate,
                isBookmark: $0.bookmarkYn,
                isLogin: loginYn
            )
        }
    }

    func makeSearchResultHeaderInput(count: Int64, title: String = Filter.shared.title) -> SearchResultHeaderView.Input {
        return SearchResultHeaderView.Input(count: Int(count), filterStatusTitle: title)
    }
}

// MARK: - Remove Funtions
private extension PopupSearchReactor {
    func removeAllRecentSearchItems() {
        userDefaultService.delete(keyType: .searchKeyword)
    }

    func removeCategoryItem(by categoryID: Int) {
        Category.shared.removeItem(by: categoryID)
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
