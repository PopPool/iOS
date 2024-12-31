import ReactorKit
import RxSwift

final class StoreListReactor: Reactor {
    // MARK: - Reactor
    enum Action {
        case viewDidLoad
        case didSelectItem(Int)
        case toggleBookmark(Int)

        // 필터칩 탭 시 (location / category)
        case filterTapped(FilterType?)
        // 바텀시트에서 필터 선택 후 save 시
        case filterUpdated(FilterType, [String])
        // 필터 제거(초기화)
        case clearFilters(FilterType)
    }

    enum Mutation {
        // 기존
        case setStores([StoreItem])
        case updateBookmark(Int)

        // 필터 관련
        case setActiveFilter(FilterType?)
        case setLocationFilters([String])
        case setCategoryFilters([String])
        case clearLocationFilters
        case clearCategoryFilters
    }

    struct State {
        // 기존
        var stores: [StoreItem] = []

        // 필터 관련 상태
        var activeFilterType: FilterType?
        var selectedLocationFilters: [String] = []
        var selectedCategoryFilters: [String] = []
    }

    // MARK: - Properties
    var initialState: State
    var disposeBag = DisposeBag()

    // MARK: - Init
    init() {
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // 1) 리스트 데이터 fetch
        case .viewDidLoad:
            return fetchStores()

        case let .didSelectItem(index):
            // TODO: item 선택 시 로직
            return .empty()

        case let .toggleBookmark(index):
            return .just(.updateBookmark(index))

        // 2) 필터칩 탭: filterTapped(.location/.category or nil)
        case let .filterTapped(filterType):
            return .just(.setActiveFilter(filterType))

        // 3) 바텀시트에서 선택된 필터 값 적용
        case let .filterUpdated(type, values):
            switch type {
            case .location:
                return .just(.setLocationFilters(values))
            case .category:
                return .just(.setCategoryFilters(values))
            }

        // 4) 필터 제거(초기화)
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

        // 기존
        case let .setStores(stores):
            newState.stores = stores

        case let .updateBookmark(index):
            if index < newState.stores.count {
                var item = newState.stores[index]
                item.isBookmarked.toggle()
                newState.stores[index] = item
            }

        // 필터관련
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
        let mockStores = [
            StoreItem(id: 1, thumbnailURL: "", category: "카페",  title: "팝업스토어1",
                      location: "서울 강남구",   dateRange: "2024.06.30 ~ 08.23",
                      isBookmarked: false),
            StoreItem(id: 2, thumbnailURL: "", category: "전시",  title: "팝업스토어2",
                      location: "서울 성동구", dateRange: "2024.07.01 ~ 07.30",
                      isBookmarked: true)
        ]
        return .just(.setStores(mockStores))
    }
}

// MARK: - Model
struct StoreItem {
    let id: Int
    let thumbnailURL: String
    let category: String
    let title: String
    let location: String
    let dateRange: String
    var isBookmarked: Bool
}
