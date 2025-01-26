import ReactorKit
import RxSwift

final class StoreListReactor: Reactor {
    // MARK: - Reactor

    private var currentPage = 0
    private let pageSize = 10
    private var hasMorePages = true

    enum Action {
        case viewDidLoad
        case didSelectItem(Int)
        case toggleBookmark(Int)
        case setStores([StoreItem])
        case filterTapped(FilterType?)
        case filterUpdated(FilterType, [String])
        case clearFilters(FilterType)
    }

    enum Mutation {
        case setStores([StoreItem])
        case updateBookmark(Int, Bool)
        case setActiveFilter(FilterType?)
        case setLocationFilters([String])
        case setCategoryFilters([String])
        case clearLocationFilters
        case clearCategoryFilters
        case showBookmarkToast(Bool)
    }

    struct State {
        var stores: [StoreItem] = []
        var activeFilterType: FilterType?
        var selectedLocationFilters: [String] = []
        var selectedCategoryFilters: [String] = []
        var shouldShowBookmarkToast: Bool = false
    }

    // MARK: - Properties
    var initialState: State
    private let userAPIUseCase: UserAPIUseCaseImpl = UserAPIUseCaseImpl(
        repository: UserAPIRepositoryImpl(provider: ProviderImpl())
    )

    init() {
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return fetchStores()

        case let .didSelectItem(index):
            // 아이템 선택 시 처리 (필요 시 구현)
            return .empty()

        case .toggleBookmark(let index):
            guard index < currentState.stores.count else { return .empty() }
            let store = currentState.stores[index]
            let isBookmarking = !store.isBookmarked

            // Completable을 Observable<Void>로 변환
            let bookmarkRequest = isBookmarking
                ? userAPIUseCase.postBookmarkPopUp(popUpID: Int64(store.id)).andThen(Observable.just(()))
                : userAPIUseCase.deleteBookmarkPopUp(popUpID: Int64(store.id)).andThen(Observable.just(()))

            return Observable.concat([
                bookmarkRequest.map { Mutation.updateBookmark(index, isBookmarking) },
                .just(.showBookmarkToast(isBookmarking))
            ])


        case let .setStores(storeItems):
            return .just(.setStores(storeItems))

        case let .filterTapped(filterType):
            return .just(.setActiveFilter(filterType))

        case let .filterUpdated(type, values):
            switch type {
            case .location:
                return .just(.setLocationFilters(values))
            case .category:
                return .just(.setCategoryFilters(values))
            }

        case let .clearFilters(type):
            switch type {
            case .location:
                return .just(.clearLocationFilters)
            case .category:
                return .just(.clearCategoryFilters)
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setStores(stores):
            newState.stores = stores

        case let .updateBookmark(index, isBookmarked):
            // 북마크 상태 업데이트
            if index < newState.stores.count {
                newState.stores[index].isBookmarked = isBookmarked

                Logger.log(
                    message: """
                    북마크 상태 업데이트:
                    - 인덱스: \(index)
                    - 북마크 상태: \(isBookmarked)
                    """,
                    category: .debug
                )
            }


        case let .showBookmarkToast(isBookmarked):
            if currentState.stores.isEmpty {
                break 
            }

            newState.shouldShowBookmarkToast = isBookmarked

        case let .setActiveFilter(filterType):
            newState.activeFilterType = filterType

        case let .setLocationFilters(filters):
            newState.selectedLocationFilters = filters

        case let .setCategoryFilters(filters):
            newState.selectedCategoryFilters = filters

        case .clearLocationFilters:
            newState.selectedLocationFilters = []

        case .clearCategoryFilters:
            newState.selectedCategoryFilters = []
        }
        return newState
    }

    // MARK: - Private
    private func fetchStores() -> Observable<Mutation> {
        return userAPIUseCase.getRecentPopUp(page: 0, size: 10, sort: nil)
            .map { response in
                let stores = response.popUpInfoList.map { $0.toStoreItem() }
                return Mutation.setStores(stores)
            }
            .catchAndReturn(.setStores([]))
    }
}


    // MARK: - Model
struct StoreItem {
    let id: Int
    let thumbnailURL: String
    let category: String
    let title: String
    let location: String
    let dateRange: String?
    var isBookmarked: Bool

    var formattedDateRange: String {
        guard let dateRange = dateRange else { return "" }
        let dates = dateRange.split(separator: "~").map {
            String($0).trimmingCharacters(in: .whitespacesAndNewlines).toDate()?.formatted() ?? String($0)
        }
        return dates.joined(separator: " ~ ")
    }
}
