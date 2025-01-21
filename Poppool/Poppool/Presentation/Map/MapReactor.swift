import ReactorKit
import RxSwift
import CoreLocation

final class MapReactor: Reactor {
    // MARK: - Reactor
    enum Action {
        case viewDidLoad
        case searchTapped(String)
        case locationButtonTapped
        case listButtonTapped
        case filterTapped(FilterType?)
        case filterUpdated(FilterType, [String])
        case clearFilters(FilterType)
        case updateBothFilters(locations: [String], categories: [String])  // 새로 추가
        case didSelectItem(MapPopUpStore)
        case viewportChanged(
            northEastLat: Double,
            northEastLon: Double,
            southWestLat: Double,
            southWestLon: Double
        )

    }

    enum Mutation {
        case setActiveFilter(FilterType?)
        case setLocationFilters([String])
        case setCategoryFilters([String])
        case updateLocationDisplay(String)
        case updateCategoryDisplay(String)
        case clearLocationFilters
        case clearCategoryFilters
        case updateBothFilters(locations: [String], categories: [String])  // 새로 추가
        case setToastMessage(String)
        case setLoading(Bool) // 검색시 로딩
        case setSearchResults([MapPopUpStore])
        case setSelectedStore(MapPopUpStore) // 선택된 스토어 상태
        case setViewportStores([MapPopUpStore])
        case setError(Error?)


    }

    struct State {
        var isLoading: Bool = false
        var searchResults: [MapPopUpStore] = []
        var searchResult: MapPopUpStore? = nil
        var toastMessage: String? = nil
        var activeFilterType: FilterType?
        var selectedLocationFilters: [String] = []
        var selectedCategoryFilters: [String] = []
        var locationDisplayText: String = "지역선택"
        var categoryDisplayText: String = "카테고리"
        var selectedStore: MapPopUpStore? // 선택된 스토어
        var viewportStores: [MapPopUpStore] = []
        var error: Error? = nil



    }

    let initialState: State
    private let useCase: MapUseCase

    init(useCase: MapUseCase) {
        self.useCase = useCase
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .searchTapped(query):
            let categories = currentState.selectedCategoryFilters
            return .concat([
                .just(.setLoading(true)), // 로딩 시작
                useCase.searchStores(query: query, categories: categories)
                    .flatMap { results -> Observable<Mutation> in
                        if results.isEmpty {
                            return .just(.setToastMessage("검색 결과가 없습니다."))
                        } else {
                            return .just(.setSearchResults(results))
                        }
                    },
                .just(.setLoading(false)) // 로딩 종료
            ])
        case let .viewportChanged(northEastLat, northEastLon, southWestLat, southWestLon):
            return .concat([
                .just(.setLoading(true)),
                useCase.fetchStoresInBounds(
                    northEastLat: northEastLat,
                    northEastLon: northEastLon,
                    southWestLat: southWestLat,
                    southWestLon: southWestLon,
                    categories: currentState.selectedCategoryFilters
                )
                .map(Mutation.setViewportStores)
                .catch { .just(.setError($0)) },
                .just(.setLoading(false))
            ])

        case let .updateBothFilters(locations, categories):
            return .concat([
                .just(.setLocationFilters(locations)),
                .just(.setCategoryFilters(categories))
            ])
        case let .filterTapped(filterType):
            return .just(.setActiveFilter(filterType))

        case let .filterUpdated(type, values):
            switch type {
            case .location:
                let displayText = formatDisplayText(values, defaultText: "지역선택")
                return .concat([
                    .just(.setLocationFilters(values)),
                    .just(.updateLocationDisplay(displayText))
                ])
            case .category:
                let displayText = formatDisplayText(values, defaultText: "카테고리")
                return .concat([
                    .just(.setCategoryFilters(values)),
                    .just(.updateCategoryDisplay(displayText))
                ])
            }
        case let .updateBothFilters(locations, categories):
            Logger.log(
                message: """
                Updating both filters:
                - Locations: \(locations)
                - Categories: \(categories)
                """,
                category: .debug
            )
            return .concat([
                .just(.setLocationFilters(locations)),
                .just(.setCategoryFilters(categories))
            ])

        case let .clearFilters(type):
            switch type {
            case .location:
                return .concat([
                    .just(.clearLocationFilters),
                    .just(.updateLocationDisplay("지역선택"))
                ])
            case .category:
                return .concat([
                    .just(.clearCategoryFilters),
                    .just(.updateCategoryDisplay("카테고리"))
                ])
            }
        case let .didSelectItem(store):
            return .just(.setSelectedStore(store))
        default:
            return .empty()
        }
    }

    private func formatDisplayText(_ values: [String], defaultText: String) -> String {
        guard !values.isEmpty else { return defaultText }
        return values.count > 1 ? "\(values[0]) 외 \(values.count - 1)개" : values[0]
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading

        case let .setSearchResults(results):
            newState.searchResults = results

        case let .setToastMessage(message):
            newState.toastMessage = message

        case let .setActiveFilter(filterType):
            newState.activeFilterType = filterType
            print("[DEBUG] 🎯 Active Filter Changed: \(String(describing: filterType))")

        case let .setLocationFilters(filters):
            newState.selectedLocationFilters = filters
            print("Updating selectedLocationFilters to: \(filters)")

        case let .setCategoryFilters(filters):
            newState.selectedCategoryFilters = filters
            print("[DEBUG] 🔄 Category Filters Updated: \(filters)")

        case let .updateLocationDisplay(text):
            newState.locationDisplayText = text

        case let .updateCategoryDisplay(text):
            newState.categoryDisplayText = text

        case .clearLocationFilters:
            newState.selectedLocationFilters = []

        case .clearCategoryFilters:
            newState.selectedCategoryFilters = []

        case let .updateBothFilters(locations, categories):
            print("[DEBUG] 💾 Reducing both filters update")
            print("[DEBUG] 📍 Previous state - Locations: \(newState.selectedLocationFilters)")
            print("[DEBUG] 🏷️ Previous state - Categories: \(newState.selectedCategoryFilters)")

            newState.selectedLocationFilters = locations
            newState.selectedCategoryFilters = categories

            print("[DEBUG] ✅ Updated state - Locations: \(newState.selectedLocationFilters)")
            print("[DEBUG] ✅ Updated state - Categories: \(newState.selectedCategoryFilters)")

        case let .setViewportStores(stores):
            newState.viewportStores = stores

        case let .setSelectedStore(store):
            newState.selectedStore = store
            print("[DEBUG] 📍 Selected Store: \(store.name)")
        case let .setError(error):
            newState.error = error
            if let error = error {
                Logger.log(
                    message: """
                    Error occurred in MapReactor:
                    - Description: \(error.localizedDescription)
                    - Domain: \(String(describing: (error as NSError).domain))
                    - Code: \((error as NSError).code)
                    """,
                    category: .error
                )
            }

        }
        return newState

    }
}
