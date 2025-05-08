import CoreLocation

import DomainInterface
import Infrastructure

import ReactorKit
import RxSwift

final class MapReactor: Reactor {
    // MARK: - Reactor
    enum Action {
        case viewDidLoad(Int64)
        case searchTapped(String)
        case locationButtonTapped
        case listButtonTapped
        case filterTapped(FilterType?)
        case filterUpdated(FilterType, [String])
        case clearFilters(FilterType)
        case fetchCategories
        case updateBothFilters(locations: [String], categories: [String])  // 새로 추가
        case didSelectItem(MapPopUpStore)
        case fetchAllStores
        case refreshMarkers(northEastLat: Double, northEastLon: Double, southWestLat: Double, southWestLon: Double)
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
        case setSearchResult(MapPopUpStore)
        case setSelectedStore(MapPopUpStore) // 선택된 스토어 상태
        case setViewportStores([MapPopUpStore])
        case setError(Error?)
        case setCategoryMapping([String: Int])
    }

    struct State {
        var isLoading: Bool = false
        var searchResults: [MapPopUpStore] = []
        var searchResult: MapPopUpStore? = nil
        var toastMessage: String? = nil
        var activeFilterType: FilterType?
        var selectedLocationFilters: [String] = []
        var selectedCategoryFilters: [String] = []
        var tempLocationFilters: [String] = []
        var tempCategoryFilters: [String] = []
        var locationDisplayText: String = "지역선택"
        var categoryDisplayText: String = "카테고리"
        var selectedStore: MapPopUpStore? = nil // 선택된 스토어
        var viewportStores: [MapPopUpStore] = []
        var error: Error? = nil
        var categoryMapping: [String: Int] = [:]
    }

    let initialState: State
    private let mapUseCase: MapUseCase
    private let mapDirectionRepository: MapDirectionRepository

    init(mapUseCase: MapUseCase, mapDirectionRepository: MapDirectionRepository) {
        self.mapUseCase = mapUseCase
        self.mapDirectionRepository = mapDirectionRepository
        self.initialState = State()
    }
    private func store(_ store: MapPopUpStore, matches filter: String) -> Bool {
        let normalizedAddress = store.address.lowercased()
        if filter.contains("/") {
            let individualFilters = filter
                .components(separatedBy: "/")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            return individualFilters.contains { normalizedAddress.contains($0) }
        } else {
            let normalizedFilter = filter.hasSuffix("전체")
                ? filter.replacingOccurrences(of: "전체", with: "").lowercased()
                : filter.lowercased()
            return normalizedAddress.contains(normalizedFilter)
        }
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchCategories:
            return mapUseCase.fetchCategories()
                .map { categories in
                    let mapping = categories.reduce(into: [String: Int]()) { dict, category in
                        dict[category.category] = category.categoryId
                    }
                    return .setCategoryMapping(mapping)
                }
                .catch { error in
                    return .just(.setError(error))
                }

        case let .searchTapped(query):
            let categoryIDs = currentState.selectedCategoryFilters
                .compactMap { currentState.categoryMapping[$0] }
            return .concat([
                .just(.setSearchResults([])),
                .just(.setLoading(true)),
                mapUseCase.searchStores(query: query, categories: categoryIDs)
                    .flatMap { results -> Observable<Mutation> in
                        if results.isEmpty {
                            return .just(.setToastMessage("검색 결과가 없습니다."))
                        } else {
                            return .just(.setSearchResults(results))
                        }
                    },
                .just(.setLoading(false))
            ])

        case let .viewportChanged(northEastLat, northEastLon, southWestLat, southWestLon):
            let categoryIDs = currentState.selectedCategoryFilters
                .compactMap { currentState.categoryMapping[$0] }

            return .concat([
                .just(.setLoading(true)),
                mapUseCase.fetchStoresInBounds(
                    northEastLat: northEastLat,
                    northEastLon: northEastLon,
                    southWestLat: southWestLat,
                    southWestLon: southWestLon,
                    categories: categoryIDs
                )
                .map { stores -> Mutation in
                    var filteredStores = stores

                    let locationFilters = self.currentState.selectedLocationFilters
                    if !locationFilters.isEmpty {
                        filteredStores = stores.filter { store in
                            return locationFilters.contains { filter in
                                return self.store(store, matches: filter)
                            }
                        }
                    }

                    // 선택한 스토어가 있다면 리스트 맨 앞에 삽입
                    if let selectedStore = self.currentState.selectedStore {
                        filteredStores.removeAll { $0.id == selectedStore.id }
                        filteredStores.insert(selectedStore, at: 0)
                    }

                    return .setViewportStores(filteredStores)
                }
                .catch { error in .just(.setError(error)) },
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

        case .refreshMarkers(let northEastLat, let northEastLon, let southWestLat, let southWestLon):
            let categoryIDs = currentState.selectedCategoryFilters
                .compactMap { currentState.categoryMapping[$0] }
            return Observable.concat([
                Observable.just(.setLoading(true)),
                mapUseCase.fetchStoresInBounds(
                    northEastLat: northEastLat,
                    northEastLon: northEastLon,
                    southWestLat: southWestLat,
                    southWestLon: southWestLon,
                    categories: categoryIDs
                )
                .map { stores -> Mutation in
                    let filteredStores = stores
                    return .setViewportStores(filteredStores)
                }
                .catch { error in Observable.just(.setError(error)) },
                Observable.just(.setLoading(false))
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

        case .viewDidLoad(let id):
            return mapDirectionRepository.getPopUpDirection(popUpStoreId: id)
                .do(
                    onNext: { _ in
                    },
                    onError: { error in
                        Logger.log(
                            message: "❌ [에러]: 요청 실패 - \(error.localizedDescription)",
                            category: .error
                        )
                    },
                    onSubscribe: { }
                )
                .map { response in
                    return MapPopUpStore(
                        id: response.id,
                        category: response.categoryName,
                        name: response.name,
                        address: response.address,
                        startDate: response.startDate,
                        endDate: response.endDate,
                        latitude: response.latitude,
                        longitude: response.longitude,
                        markerId: response.markerId,
                        markerTitle: response.markerTitle,
                        markerSnippet: response.markerSnippet,
                        mainImageUrl: ""
                    )
                }
                .map { store in
                    return .setSearchResult(store)
                }
        case .fetchAllStores:
            // 한국 전체 영역에 대한 바운드 설정
            let koreaRegion = (
                northEast: (lat: 38.0, lon: 132.0),
                southWest: (lat: 33.0, lon: 124.0)
            )

            let categoryIDs = currentState.selectedCategoryFilters
                .compactMap { currentState.categoryMapping[$0] }

            return .concat([
                .just(.setLoading(true)),
                mapUseCase.fetchStoresInBounds(
                    northEastLat: koreaRegion.northEast.lat,
                    northEastLon: koreaRegion.northEast.lon,
                    southWestLat: koreaRegion.southWest.lat,
                    southWestLon: koreaRegion.southWest.lon,
                    categories: categoryIDs
                )
                .map { stores -> Mutation in
                    var filteredStores = stores

                    let locationFilters = self.currentState.selectedLocationFilters
                    if !locationFilters.isEmpty {
                        filteredStores = stores.filter { store in
                            return locationFilters.contains { filter in
                                return self.store(store, matches: filter)
                            }
                        }
                    }

                    return .setViewportStores(filteredStores)
                }
                .catch { error in .just(.setError(error)) },
                .just(.setLoading(false))
            ])

        case let .didSelectItem(store):
            return .concat([
                .just(.setSelectedStore(store)),
                .just(.setViewportStores(currentState.viewportStores)) // ✅ 선택된 마커를 캐러셀에서 최우선으로 반영
            ])

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

        case let .setSearchResult(store):
            newState.searchResult = store

        case let .setToastMessage(message):
            newState.toastMessage = message

        case let .setActiveFilter(filterType):
            newState.activeFilterType = filterType

        case let .setLocationFilters(filters):
            newState.selectedLocationFilters = filters

        case let .setCategoryFilters(filters):
            newState.selectedCategoryFilters = filters

        case let .updateLocationDisplay(text):
            newState.locationDisplayText = text

        case let .updateCategoryDisplay(text):
            newState.categoryDisplayText = text

        case .clearLocationFilters:
            newState.selectedLocationFilters = []

        case .clearCategoryFilters:
            newState.selectedCategoryFilters = []

        case let .updateBothFilters(locations, categories):
            newState.selectedLocationFilters = locations
            newState.selectedCategoryFilters = categories

        case let .setViewportStores(stores):
            // ✅ 선택된 스토어가 있다면, 맨 앞에 배치
            var updatedStores = stores
            if let selectedStore = state.selectedStore {
                updatedStores.removeAll { $0.id == selectedStore.id }
                updatedStores.insert(selectedStore, at: 0) // 🔥 선택된 마커를 캐러셀의 첫 번째로 설정
            }

            Logger.log(
                message: """
                Updated viewport stores:
                - Total: \(updatedStores.count)
                - Selected Store: \(state.selectedStore?.name ?? "None")
                """,
                category: .debug
            )

            newState.viewportStores = updatedStores

        case let .setSelectedStore(store):
            newState.selectedStore = store

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

        case let .setCategoryMapping(mapping):
            newState.categoryMapping = mapping
        }
        return newState
    }
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        return Array(Set(self))
    }
}
