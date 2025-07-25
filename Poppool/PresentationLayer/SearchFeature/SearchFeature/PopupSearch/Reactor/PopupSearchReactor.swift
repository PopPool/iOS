import Foundation

import DomainInterface
import Infrastructure

import ReactorKit
import RxCocoa
import RxSwift

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
        case searchResultBookmarkButtonTapped(indexPath: IndexPath)
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
        case updateSearchResultBookmark(indexPath: IndexPath)
        case updateSearchResultSection

        case present(target: PresentTarget)
    }

    @frozen
    public enum PresentTarget {
        case categorySelector
        case filterSelector
        case popupDetail(popupID: Int)
        case before
    }

    public struct State {
        var recentSearchItems: [TagModel] = []
        var categoryItems: [TagModel] = []
        var searchResultItems: [SearchResultModel] = []
        var searchResultHeader: SearchResultHeaderModel = SearchResultHeaderModel(filterText: Filter.shared.title)

        @Pulse var searchBarText: String? = nil
        @Pulse var present: PresentTarget?
        @Pulse var clearButtonIsHidden: Bool?
        @Pulse var endEditing: Void?
        @Pulse var updateSearchResultSection: String?
        @Pulse var dismiss: Void?

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
    private let userAPIUseCase: UserAPIUseCase
    private let fetchKeywordBasePopupListUseCase: FetchKeywordBasePopupListUseCase

    // MARK: - init
    public init(
        popupAPIUseCase: PopUpAPIUseCase,
        userAPIUseCase: UserAPIUseCase,
        fetchKeywordBasePopupListUseCase: FetchKeywordBasePopupListUseCase
    ) {
        self.popupAPIUseCase = popupAPIUseCase
        self.userAPIUseCase = userAPIUseCase
        self.fetchKeywordBasePopupListUseCase = fetchKeywordBasePopupListUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return handleViewDidLoad()

        case .searchBarEditing(let text):
            return handleSearchBarEditing(text)

        case .searchBarExitEditing(let text):
            return handleSearchBarExitEditing(text)

        case .searchBarEndEditing:
            return handleSearchBarEndEditing()

        case .searchBarClearButtonTapped:
            return handleSearchBarClear()

        case .searchBarCancelButtonTapped:
            return handleSearchBarCancel()

        case .recentSearchTagButtonTapped(let indexPath):
            return handleRecentSearchTagTap(at: indexPath)

        case .recentSearchTagRemoveButtonTapped(let text):
            return handleRecentSearchTagRemove(text)

        case .recentSearchTagRemoveAllButtonTapped:
            return handleRecentSearchTagRemoveAll()

        case .categoryTagRemoveButtonTapped(let categoryID):
            return handleCategoryTagRemove(categoryID)

        case .categoryTagButtonTapped:
            return .just(.present(target: .categorySelector))

        case .categoryChangedBySelector:
            return handleCategoryChanged()

        case .searchResultFilterButtonTapped:
            return .just(.present(target: .filterSelector))

        case .searchResultFilterChangedBySelector:
            return handleFilterChanged()

        case .searchResultItemTapped(let indexPath):
            return handleSearchResultItemTap(at: indexPath)

        case .searchResultBookmarkButtonTapped(let indexPath):
            return handleSearchResultBookmark(at: indexPath)

        case .searchResultPrefetchItems(let indexPathList):
            return handleSearchResultPrefetch(at: indexPathList)
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
            // TODO: 캡슐화 진행해주기
            // TODO: 페이지네이션에서 왜 중복된 아이템이 내려오는지 이유 알기
            let currentItemsSet = Set(newState.searchResultItems)
            let appendItemsSet = Set(items)
            let newItems = Array(appendItemsSet.subtracting(currentItemsSet))

            newState.searchResultItems += newItems

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

        case .updateSearchResultBookmark(let indexPath):
            newState.searchResultItems[indexPath.item].isBookmark.toggle()

        case .updateSearchResultSection:
            newState.updateSearchResultSection = makeSearchResultEmpty(state: newState)

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

    func fetchSearchResultBookmark(at indexPath: IndexPath) -> Completable {
        let popupID = currentState.searchResultItems[indexPath.item].id
        if currentState.searchResultItems[indexPath.item].isBookmark {
            return userAPIUseCase.deleteBookmarkPopUp(popUpID: popupID)
        } else {
            return userAPIUseCase.postBookmarkPopUp(popUpID: popupID)
        }
    }
}

// MARK: - Make Functions
private extension PopupSearchReactor {
    func findRecentSearchKeyword(at indexPath: IndexPath) -> String? {
        guard currentState.recentSearchItems.indices.contains(indexPath.item)
        else { return nil }

        return currentState.recentSearchItems[indexPath.item].title
    }

    func makeRecentSearchItems() -> [TagModel] {
        let searchKeywords = userDefaultService.fetchArray(keyType: .searchKeyword) ?? []
        return searchKeywords.prefix(10).map { TagModel(title: $0) }
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

    // 빈 화면에서 탭할때 문제
    func findPopupStoreID(at indexPath: IndexPath) -> Int? {
        guard currentState.searchResultItems.indices.contains(indexPath.item) else { return nil }
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

    func makeSearchResultEmpty(state: State) -> String? {
        if !currentState.searchResultItems.isEmpty { return nil } else if currentState.isSearching { return "검색 결과가 없어요 :(\n다른 키워드로 검색해주세요" } else { return "검색 결과가 없어요 :(\n다른 옵션을 선택해주세요" }
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

// MARK: - Mutate Handlers
private extension PopupSearchReactor {
    func handleViewDidLoad() -> Observable<Mutation> {
        return loadDefaultSearchResults()
    }

    func handleSearchBarEditing(_ text: String) -> Observable<Mutation> {
        return .just(.updateClearButtonIsHidden(to: text.isEmpty))
    }

    func handleSearchBarExitEditing(_ text: String) -> Observable<Mutation> {
        return loadKeywordSearchResults(text)
    }

    func handleSearchBarEndEditing() -> Observable<Mutation> {
        return Observable.concat([
            .just(.updateClearButtonIsHidden(to: true)),
            .just(.updateEditingState)
        ])
    }

    func handleSearchBarClear() -> Observable<Mutation> {
        return Observable.concat([
            .just(.updateClearButtonIsHidden(to: true)),
            .just(.updateSearchBar(to: nil))
        ])
    }

    func handleSearchBarCancel() -> Observable<Mutation> {
        if currentState.isSearching {
            return loadDefaultSearchResults()
        } else {
            return .just(.present(target: .before))
        }
    }

    func handleRecentSearchTagTap(at indexPath: IndexPath) -> Observable<Mutation> {
        let keyword = findRecentSearchKeyword(at: indexPath)
        return loadKeywordSearchResults(keyword)
    }

    func handleRecentSearchTagRemove(_ text: String) -> Observable<Mutation> {
        removeRecentSearchItem(text: text)
        return Observable.concat([
            .just(.setupRecentSearch(items: makeRecentSearchItems())),
            .just(.updateSearchResultSection)
        ])
    }

    func handleRecentSearchTagRemoveAll() -> Observable<Mutation> {
        removeAllRecentSearchItems()
        return Observable.concat([
            .just(.setupRecentSearch(items: makeRecentSearchItems())),
            .just(.updateSearchResultSection)
        ])
    }

    func handleCategoryTagRemove(_ categoryID: Int) -> Observable<Mutation> {
        removeCategoryItem(by: categoryID)
        return loadDefaultSearchResults()
    }

    func handleCategoryChanged() -> Observable<Mutation> {
        return loadDefaultSearchResults()
    }

    func handleFilterChanged() -> Observable<Mutation> {
        return loadDefaultSearchResults()
    }

    func handleSearchResultItemTap(at indexPath: IndexPath) -> Observable<Mutation> {
        guard let popupID = findPopupStoreID(at: indexPath) else { return .empty() }
        return .just(.present(target: .popupDetail(popupID: popupID)))
    }

    func handleSearchResultBookmark(at indexPath: IndexPath) -> Observable<Mutation> {
        return fetchSearchResultBookmark(at: indexPath)
            .andThen(.concat([
                .just(.updateSearchResultBookmark(indexPath: indexPath)),
                .just(.updateSearchResultSection)
            ]))
    }

    func handleSearchResultPrefetch(at indexPathList: [IndexPath]) -> Observable<Mutation> {
        guard isPrefetchable(prefetchCount: 4, indexPathList: indexPathList) else { return .empty() }
        return fetchSearchResult(page: currentState.currentPage + 1)
            .withUnretained(self)
            .flatMap { owner, response in
                Observable.concat([
                    .just(.appendSearchResult(items: owner.makeSearchResultItems(response.popUpStoreList, response.loginYn))),
                    .just(.updateCurrentPage(to: owner.currentState.currentPage + 1)),
                    .just(.updateSearchResultSection)
                ])
            }
    }
}

// MARK: - Load Search Results
private extension PopupSearchReactor {
    func loadDefaultSearchResults(page: Int32 = 0) -> Observable<Mutation> {
        return fetchSearchResult(page: page)
            .withUnretained(self)
            .flatMap { owner, response in
                Observable.concat([
                    .just(.setupRecentSearch(items: owner.makeRecentSearchItems())),
                    .just(.setupCategory(items: owner.makeCategoryItems())),
                    .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(count: response.totalElements))),
                    .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popUpStoreList, response.loginYn))),
                    .just(.setupSearchResultTotalPageCount(count: response.totalPages)),
                    .just(.updateCurrentPage(to: 0)),
                    .just(.updateSearchingState(to: false)),
                    .just(.updateSearchBar(to: nil)),
                    .just(.updateEditingState),
                    .just(.updateSearchResultSection)
                ])
            }
    }

    func loadKeywordSearchResults(_ keyword: String?) -> Observable<Mutation> {
        guard let keyword = keyword else { return .empty() }
        return fetchSearchResult(keyword: keyword)
            .withUnretained(self)
            .flatMap { owner, response in
                Observable.concat([
                    .just(.setupRecentSearch(items: [])),
                    .just(.setupCategory(items: [])),
                    .just(.setupSearchResult(items: owner.makeSearchResultItems(response.popupStoreList, response.loginYn))),
                    .just(.setupSearchResultHeader(item: owner.makeSearchResultHeaderInput(
                        keyword: owner.makePostPositionedText(keyword),
                        count: Int64(response.popupStoreList.count)
                    ))),
                    .just(.setupSearchResultTotalPageCount(count: 0)),
                    .just(.updateCurrentPage(to: 0)),
                    .just(.updateSearchingState(to: true)),
                    .just(.updateClearButtonIsHidden(to: true)),
                    .just(.updateEditingState),
                    .just(.updateSearchResultSection)
                ])
            }
    }
}
