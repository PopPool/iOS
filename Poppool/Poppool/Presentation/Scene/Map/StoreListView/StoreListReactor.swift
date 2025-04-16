import Foundation
import ReactorKit
import RxCocoa
import RxSwift

final class StoreListReactor: Reactor {
    // MARK: - Reactor
    private let userAPIUseCase: UserAPIUseCaseImpl
    private let popUpAPIUseCase: PopUpAPIUseCaseImpl
    private let bookmarkStateRelay = PublishRelay<(Int64, Bool)>()

    enum Action {
        case syncBookmarkStatus(storeId: Int64, isBookmarked: Bool)
        case didSelectItem(Int)
        case toggleBookmark(Int)
        case setStores([StoreItem])
        case filterTapped(FilterType?)
        case filterUpdated(FilterType, [String])
        case clearFilters(FilterType)
        case updateStoreBookmark(id: Int64, isBookmarked: Bool)  // 추가

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

    init(
        userAPIUseCase: UserAPIUseCaseImpl = UserAPIUseCaseImpl(repository: UserAPIRepositoryImpl(provider: ProviderImpl())),
        popUpAPIUseCase: PopUpAPIUseCaseImpl = PopUpAPIUseCaseImpl(repository: PopUpAPIRepositoryImpl(provider: ProviderImpl()))
    ) {
        self.userAPIUseCase = userAPIUseCase
        self.popUpAPIUseCase = popUpAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {

                case let .syncBookmarkStatus(storeId, isBookmarked):
                    if let index = currentState.stores.firstIndex(where: { $0.id == storeId }) {
                        return .just(.updateBookmark(index, isBookmarked))
                    }
                    return .empty()
        case let .didSelectItem(index):
            // 아이템 선택 시 처리 (필요 시 구현)
            return .empty()

        case .toggleBookmark(let index):
            guard index < currentState.stores.count else { return .empty() }
            let store = currentState.stores[index]
            let isBookmarking = !store.isBookmarked

            // Int64 → Int32 변환 필요
            guard let idInt32 = Int32(exactly: store.id) else {
                return .empty()
            }

            return popUpAPIUseCase.getPopUpDetail(
                commentType: "NORMAL",
                popUpStoredId: Int64(idInt32)
            )
            .flatMap { detail -> Observable<Mutation> in
                if detail.bookmarkYn != store.isBookmarked {
                    return .just(.updateBookmark(index, detail.bookmarkYn))
                }

                return (isBookmarking
                    ? self.userAPIUseCase.postBookmarkPopUp(popUpID: store.id)
                    : self.userAPIUseCase.deleteBookmarkPopUp(popUpID: store.id))
                    .andThen(Observable.concat([
                        .just(.updateBookmark(index, isBookmarking)),
                        .just(.showBookmarkToast(isBookmarking))
                    ]))
            }

//
//        case let .setStores(storeItems):
//            return Observable.from(storeItems)
//                .flatMap { [weak self] store -> Observable<StoreItem> in
//                    guard let self = self else { return .empty() }
//                    return self.popUpAPIUseCase.getPopUpDetail(
//                        commentType: "NORMAL",
//                        popUpStoredId: store.id
//                    )
//                    .map { detail in
//                        var updatedStore = store
//                        updatedStore.isBookmarked = detail.bookmarkYn
//                        return updatedStore
//                    }
//                    .asObservable()
//                }
//                .toArray()
//                .map { updatedStores in .setStores(updatedStores) }
//                .asObservable()
        case let .setStores(storeItems):
            // 먼저 기존 순서로 저장
            let orderMap = Dictionary(uniqueKeysWithValues: storeItems.enumerated().map { ($0.element.id, $0.offset) })

            return Observable.from(storeItems)
                .flatMap { [weak self] store -> Observable<StoreItem> in
                    guard let self = self else { return .empty() }
                    return self.popUpAPIUseCase.getPopUpDetail(
                        commentType: "NORMAL",
                        popUpStoredId: store.id,
                        isViewCount: false
                    )
                    .map { detail in
                        var updatedStore = store
                        updatedStore.isBookmarked = detail.bookmarkYn
                        return updatedStore
                    }
                    .asObservable()
                }
                .toArray()
                .map { storeItems in
                    // 원본 순서대로 정렬
                    let sortedItems = storeItems.sorted {
                        orderMap[$0.id, default: 0] < orderMap[$1.id, default: 0]
                    }
                    return .setStores(sortedItems)
                }
                .asObservable()

        case let .updateStoreBookmark(id, isBookmarked):
            // 개별 스토어의 북마크 상태만 업데이트
            if let index = currentState.stores.firstIndex(where: { $0.id == id }) {
                return .just(.updateBookmark(index, isBookmarked))
            }
            return .empty()

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
            if index < newState.stores.count {
                let store = newState.stores[index]
                let prevState = store.isBookmarked
                newState.stores[index].isBookmarked = isBookmarked

                Logger.log(
                    message: """
                    북마크 상태 변경:
                    - 스토어명: \(store.title)
                    - ID: \(store.id)
                    - 변경: \(prevState ? "ON" : "OFF") → \(isBookmarked ? "ON" : "OFF")
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

    func updateBookmarkState(storeId: Int64, isBookmarked: Bool) {
        bookmarkStateRelay.accept((storeId, isBookmarked))
    }

}

    // MARK: - Model
struct StoreItem {
    let id: Int64
    let thumbnailURL: String
    let category: String
    let title: String
    let location: String
    let dateRange: String?
    var isBookmarked: Bool

    var formattedDateRange: String {
        guard let dateRange = dateRange else { return "" }
        let dates = dateRange.split(separator: "~").map { dateStr -> String in
            let trimmed = String(dateStr).trimmingCharacters(in: .whitespacesAndNewlines)
            if let date = trimmed.toDate() {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy. MM. dd"
                return formatter.string(from: date)
            }
            return trimmed
        }
        return dates.joined(separator: " ~ ")
    }

}
