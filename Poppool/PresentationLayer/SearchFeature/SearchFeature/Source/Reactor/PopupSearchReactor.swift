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

        case recentSearchTagButtonTapped(indexPath: IndexPath)
        case recentSearchTagRemoveButtonTapped(text: String)
        case recentSearchTagRemoveAllButtonTapped

        case categoryTagRemoveButtonTapped(categoryID: Int)
        case categoryTagButtonTapped
        case categoryChangedBySelector

        case searchResultFilterButtonTapped
        case searchResultFilterChangedBySelector
        case searchResultItemTapped(indexPath: IndexPath)
        case searchResultPrefetchItems(indexPathList: [IndexPath])
    }

    public enum Mutation {
        case setupRecentSearch(items: [TagModel])
        case setupCategory(items: [TagModel])
        case setupSearchResult(items: [SearchResultModel])
        case setupSearchResultHeader(item: SearchResultHeaderModel)
        case setupSearchResultTotalPageCount(count: Int32)

        case appendSearchResult(items: [SearchResultModel])

        case updateEditingState
        case updateSearchBar(to: String?)
        case updateClearButtonIsHidden(to: Bool)
        case updateCurrentPage(to: Int32)
        case updateSearchingState(to: Bool)
        case updateSearchResultEmptyTitle
        case updateDataSource

        case present(target: PresentTarget)
    }

    public enum PresentTarget {
        case categorySelector
        case filterSelector
        case popupDetail(popupID: Int)
    }

    public struct State {
        var recentSearchItems: [TagModel] = []
        var categoryItems: [TagModel] = []
        var searchResultItems: [SearchResultModel] = []
        var searchResultHeader: SearchResultHeaderModel? = nil
        var searchResultEmptyTitle: String?

        @Pulse var searchBarText: String? = nil
        @Pulse var present: PresentTarget?
        @Pulse var clearButtonIsHidden: Bool?
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
                        .just(.updateSearchResultEmptyTitle),
                        .just(.updateDataSource)
                    ])
                }

        case .searchBarEditing(let text):
            return .just(.updateClearButtonIsHidden(to: text.isEmpty ? true : false))

        case .searchBarExitEditing(let text):
            return fetchSearchResult(keyword: text)
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return Observable.concat([
                        .just(.setupRecentSearch(items: [])),
                        .just(.setupCategory(items: [])),
                        .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popupStoreList, response.loginYn))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(
                            keyword: owner.makePostPositionedText(text),
                            count: Int64(response.popupStoreList.count)
                        ))), // FIXME: API에 해당 결과값이 아직 없음
                        .just(.setupSearchResultTotalPageCount(count: 0)),  // FIXME: API에 해당 결과값이 아직 없음
                        .just(.updateCurrentPage(to: 0)),
                        .just(.updateSearchingState(to: true)),
                        .just(.updateSearchResultEmptyTitle),
                        .just(.updateClearButtonIsHidden(to: true)),
                        .just(.updateEditingState),
                        .just(.updateDataSource)
                    ])
                }

        case .searchBarEndEditing:
            return .concat([
                .just(.updateClearButtonIsHidden(to: true)),
                .just(.updateEditingState)
            ])

        case .searchBarClearButtonTapped:
            return Observable.concat([
                .just(.updateClearButtonIsHidden(to: true)),
                .just(.updateSearchBar(to: nil))
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
                            .just(.updateSearchingState(to: false)),
                            .just(.updateSearchResultEmptyTitle),
                            .just(.updateSearchBar(to: nil)),
                            .just(.updateEditingState),
                            .just(.updateDataSource)
                        ])
                    }
            }
            else { return .empty() }    // TODO: 이전 화면으로 보내기

        case .recentSearchTagButtonTapped(let indexPath):
            let keyword = self.makeRecentSearchItem(at: indexPath)
            return fetchSearchResult(keyword: keyword)
                .withUnretained(self)
                .flatMap { (owner, response) -> Observable<Mutation> in
                    return Observable.concat([
                        .just(.setupRecentSearch(items: [])),
                        .just(.setupCategory(items: [])),
                        .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popupStoreList, response.loginYn))),
                        .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(
                            keyword: owner.makePostPositionedText(keyword),
                            count: Int64(response.popupStoreList.count)
                        ))),
                        .just(.setupSearchResultTotalPageCount(count: 0)),  // FIXME: API에 해당 결과값이 아직 없음
                        .just(.updateCurrentPage(to: 0)),
                        .just(.updateSearchBar(to: keyword)),
                        .just(.updateSearchingState(to: true)),
                        .just(.updateSearchResultEmptyTitle),
                        .just(.updateClearButtonIsHidden(to: true)),
                        .just(.updateEditingState),
                        .just(.updateDataSource)
                    ])
                }

        case .recentSearchTagRemoveButtonTapped(let text):
            self.removeRecentSearchItem(text: text)
            return Observable.concat([
                .just(.setupRecentSearch(items: self.makeRecentSearchItems())),
                .just(.updateDataSource)
            ])

        case .recentSearchTagRemoveAllButtonTapped:
            self.removeAllRecentSearchItems()
            return .concat([
                .just(.setupRecentSearch(items: self.makeRecentSearchItems())),
                .just(.updateDataSource)
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
                        .just(.updateSearchResultEmptyTitle),
                        .just(.updateDataSource)
                    ])
                }

        case .categoryTagButtonTapped:
            return .just(.present(target: .categorySelector))

        case .categoryChangedBySelector:
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
                        .just(.updateSearchResultEmptyTitle),
                        .just(.updateDataSource)
                    ])
            }

        case .searchResultFilterButtonTapped:
            return .just(.present(target: .filterSelector))

        case .searchResultFilterChangedBySelector:
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
                        .just(.updateSearchResultEmptyTitle),
                        .just(.updateDataSource)
                    ])
            }

        case .searchResultItemTapped(let indexPath):
            return .just(.present(target: .popupDetail(popupID: self.findPopupStoreID(at: indexPath))))

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

        case .setupSearchResultHeader(let input):
            newState.searchResultHeader = input

        case .setupSearchResultTotalPageCount(let count):
            newState.totalPagesCount = count

        case .appendSearchResult(let items):
            newState.searchResultItems += items

        case .updateEditingState:
            newState.endEditing = ()

        case .updateSearchBar(let text):
            newState.searchBarText = text

        case .updateClearButtonIsHidden(let state):
            newState.clearButtonIsHidden = state

        case .updateCurrentPage(let currentPage):
            newState.currentPage = currentPage

        case .updateSearchingState(let isSearching):
            newState.isSearching = isSearching

        case .updateSearchResultEmptyTitle:
            newState.searchResultEmptyTitle = makeSearchResultEmptyTitle(state: newState)

        case .updateDataSource:
            newState.updateDataSource = ()

        case .present(let target):
            newState.present = target
        }

        return newState
    }
}

// MARK: Captulation Mutate
private extension PopupSearchReactor {

    func fetchSearchResult(
        isOpen: Bool = Filter.shared.status.requestValue,
        categories: [Int] = Category.shared.getSelectedCategoryIDs(),
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

    func fetchSearchResult(keyword: String?) -> Observable<KeywordBasePopupStoreListResponse> {
        guard let keyword else { return .empty() }
        return fetchKeywordBasePopupListUseCase.execute(keyword: keyword)
    }
}

// MARK: - Make Functions
private extension PopupSearchReactor {
    func makeRecentSearchItem(at indexPath: IndexPath) -> String? {
        guard let searchKeywords = userDefaultService.fetchArray(keyType: .searchKeyword),
              searchKeywords.indices.contains(indexPath.item) else { return nil }
        return searchKeywords[indexPath.item]
    }

    func makeRecentSearchItems() -> [TagModel] {
        let searchKeywords = userDefaultService.fetchArray(keyType: .searchKeyword) ?? []
        return searchKeywords.map { TagModel(title: $0) }
    }

    func makeCategoryItems() -> [TagModel] {
        return Category.shared.getCancelableCategoryItems()
    }

    func makeSearchResultItems(_ popupStoreList: [PopUpStoreResponse], _ loginYn: Bool) -> [SearchResultModel] {
        return popupStoreList.map {
            SearchResultModel(
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

    func findPopupStoreID(at indexPath: IndexPath) -> Int {
        return Int(currentState.searchResultItems[indexPath.item].id)
    }

    func makeSearchResultHeaderInput(
        keyword afterTitle: String? = nil,
        count: Int64,
        filter filterTitle: String? = Filter.shared.title) -> SearchResultHeaderModel {
        return SearchResultHeaderModel(
            title: afterTitle,
            count: Int(count),
            filterText: filterTitle
        )
    }

    func makeSearchResultEmptyTitle(state: State) -> String? {
        if !currentState.searchResultItems.isEmpty { return nil }
        else if currentState.isSearching { return "검색 결과가 없어요 :(\n다른 키워드로 검색해주세요" }
        else { return "검색 결과가 없어요 :(\n다른 옵션을 선택해주세요" }
    }

    /// 받침에 따라 이/가 를 판단해서 붙여준다.
    func makePostPositionedText(_ text: String?) -> String {

        guard let text, let lastCharacter = text.last else { return "" }

        let unicodeValue = Int(lastCharacter.unicodeScalars.first!.value)

        // 한글 유니코드 범위 체크
        let base = 0xAC00
        let last = 0xD7A3
        guard base...last ~= unicodeValue else { return text + "가" }

        // 종성 인덱스 계산 (받침이 있으면 1 이상)
        let finalConsonantIndex = (unicodeValue - base) % 28
        return (finalConsonantIndex != 0) ? text + "이" : text + "가"
    }
}

// MARK: - Remove Funtions
private extension PopupSearchReactor {
    func removeRecentSearchItem(text: String) {
        guard let searchKeywords = userDefaultService.fetchArray(keyType: .searchKeyword) else { return }
        userDefaultService.save(keyType: .searchKeyword, value: searchKeywords.filter { $0 != text })
    }

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
