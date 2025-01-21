import ReactorKit
import RxSwift

final class StoreListReactor: Reactor {
    // MARK: - Reactor
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
        case setStores([StoreItem]) // 변환된 StoreItem 리스트
        case updateBookmark(Int)
        case setActiveFilter(FilterType?)
        case setLocationFilters([String])
        case setCategoryFilters([String])
        case clearLocationFilters
        case clearCategoryFilters
    }

    struct State {
        var stores: [StoreItem] = [] // 변환된 리스트
        var activeFilterType: FilterType?
        var selectedLocationFilters: [String] = []
        var selectedCategoryFilters: [String] = []
    }

    // MARK: - Properties
    var initialState: State

    init() {
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return fetchStores()

        case let .didSelectItem(index):
            print("[DEBUG] Item Selected at Index: \(index)")
            return .empty()

        case let .toggleBookmark(index):
            return .just(.updateBookmark(index))

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

        case let .updateBookmark(index):
            if index < newState.stores.count {
                var item = newState.stores[index]
                item.isBookmarked.toggle()
                newState.stores[index] = item
            }

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
            StoreItem(id: 1, thumbnailURL: "", category: "카페", title: "팝업스토어1",
                      location: "서울 강남구", dateRange: "2024.06.30 ~ 08.23",
                      isBookmarked: false),
            StoreItem(id: 2, thumbnailURL: "", category: "전시", title: "팝업스토어2",
                      location: "서울 성동구", dateRange: "2024.07.01 ~ 07.30",
                      isBookmarked: true)
        ]
        return .just(.setStores(mockStores))
    }
}
//
//extension MapPopUpStore {
//    func toStoreItem() -> StoreItem {
//        return StoreItem(
//            id: Int(id),
//            thumbnailURL: mainImageUrl ?? "", // 이미지 URL 매핑
//            category: category,
//            title: name,
//            location: address,
//            dateRange: "\(startDate) ~ \(endDate)",
//            isBookmarked: false // 기본값
//        )
//    }
//}


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
