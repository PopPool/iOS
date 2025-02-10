import ReactorKit
import RxSwift
import CoreLocation

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
        case setCategoryMapping([String: Int64])
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
        var selectedStore: MapPopUpStore? = nil // 선택된 스토어
        var viewportStores: [MapPopUpStore] = []
        var error: Error? = nil
        var categoryMapping: [String: Int64] = [:]
    }

    let initialState: State
    private let useCase: MapUseCase
    private let directionRepository: MapDirectionRepository

    init(useCase: MapUseCase, directionRepository: MapDirectionRepository) {
        self.useCase = useCase
        self.directionRepository = directionRepository
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchCategories:
            Logger.log(message: "카테고리 매핑", category: .debug)
            return useCase.fetchCategories()
                .map { categories in
                    let mapping = categories.reduce(into: [String: Int64]()) { dict, category in
                        dict[category.category] = category.categoryId
                    }
                    Logger.log(message: "생성된 카테고리 매핑: \(mapping)", category: .debug)
                    return .setCategoryMapping(mapping)
                }
                .catch { error in
                    Logger.log(message: "카테고리 매핑 생성 중 오류: \(error.localizedDescription)", category: .error)
                    return .just(.setError(error))
                }

        case let .searchTapped(query):
            let categoryIDs = currentState.selectedCategoryFilters
                .compactMap { currentState.categoryMapping[$0] }
            return .concat([
                .just(.setSearchResults([])),
                .just(.setLoading(true)),
                useCase.searchStores(query: query, categories: categoryIDs)
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

            Logger.log(
                message: """
                        지도 영역이 변경되었습니다:
                        📍 선택된 카테고리: \(currentState.selectedCategoryFilters)
                        🔢 변환된 카테고리 ID: \(categoryIDs)
                        """,
                category: .debug
            )

            return .concat([
                .just(.setLoading(true)),
                useCase.fetchStoresInBounds(
                    northEastLat: northEastLat,
                    northEastLon: northEastLon,
                    southWestLat: southWestLat,
                    southWestLon: southWestLon,
                    categories: categoryIDs   // API에는 카테고리 필터만 전달
                )
                .map { stores -> Mutation in
                    var filteredStores = stores

                    // 🛠 지역 필터 적용
                    let locationFilters = self.currentState.selectedLocationFilters
                    if !locationFilters.isEmpty {
                        filteredStores = stores.filter { store in
                            return locationFilters.contains { filter in
                                let normalizedFilter = filter.hasSuffix("전체") ? filter.replacingOccurrences(of: "전체", with: "") : filter
                                return store.address.contains(normalizedFilter)
                            }
                        }
                    }

                    // ✅ 선택한 마커가 있다면 리스트 맨 앞에 삽입
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

        case .viewDidLoad(let id):
            return directionRepository.getPopUpDirection(popUpStoreId: id)
                .do(
                    onNext: { response in
                        Logger.log(
                            message: """
                            ✅ [응답]: 요청 성공 - popUpStoreId: \(id)
                            - ID: \(response.id)
                            - 이름: \(response.name)
                            - 카테고리: \(response.categoryName)
                            - 위도: \(response.latitude), 경도: \(response.longitude)
                            - 주소: \(response.address)
                            """,
                            category: .network
                        )
                    },
                    onError: { error in
                        Logger.log(
                            message: "❌ [에러]: 요청 실패 - \(error.localizedDescription)",
                            category: .error
                        )
                    },
                    onSubscribe: {
                        Logger.log(
                            message: "🌎 [네트워크]: 요청 보냄 - popUpStoreId: \(id)",
                            category: .network
                        )
                    }
                )
                .map { dto in
                    let response = dto.toDomain()
                    Logger.log(
                        message: "🛠️ [도메인 매핑]: \(response)",
                        category: .debug
                    )
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
                    Logger.log(
                        message: "📌 [최종 데이터]: \(store)",
                        category: .debug
                    )
                    return .setSearchResult(store)
                }

        case let .didSelectItem(store):
            return .concat([
                .just(.setSelectedStore(store)),
                .just(.setViewportStores(currentState.viewportStores)), // ✅ 선택된 마커를 캐러셀에서 최우선으로 반영
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
            Logger.log(message: "🎯 단일 검색 결과 설정: \(store)", category: .debug)

        case let .setToastMessage(message):
            newState.toastMessage = message

        case let .setActiveFilter(filterType):
            newState.activeFilterType = filterType
            Logger.log(message: "🎯 Active Filter Changed: \(String(describing: filterType))", category: .debug)

        case let .setLocationFilters(filters):
            newState.selectedLocationFilters = filters
            Logger.log(message: "선택된 위치 필터가 업데이트: \(filters)", category: .debug)

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
            Logger.log(
                message: """
                💾 필터 상태 업데이트
                📍 이전 위치 필터: \(newState.selectedLocationFilters)
                🏷️ 이전 카테고리 필터: \(newState.selectedCategoryFilters)
                """,
                category: .debug
            )
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

        case let .setCategoryMapping(mapping):
            Logger.log(
                message: "카테고리 매핑 업데이트 완료: \(mapping)",
                category: .debug
            )
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
