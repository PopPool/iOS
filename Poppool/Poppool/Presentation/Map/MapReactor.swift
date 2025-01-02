import ReactorKit
import RxSwift
import CoreLocation

final class MapReactor: Reactor {
    // MARK: - Reactor
    enum Action {
        case viewDidLoad
        case searchTapped
        case locationButtonTapped
        case listButtonTapped
        case filterTapped(FilterType?)    // 여기서 FilterType은 공통 파일에서 가져옴
        case filterUpdated(FilterType, [String])
        case clearFilters(FilterType)
    }

    enum Mutation {
        case setActiveFilter(FilterType?)
        case setLocationFilters([String])
        case setCategoryFilters([String])
        case clearLocationFilters
        case clearCategoryFilters
    }

    struct State {
        var activeFilterType: FilterType?
        var selectedLocationFilters: [String] = []
        var selectedCategoryFilters: [String] = []
    }

    let initialState: State
    private let useCase: MapUseCase

    init(useCase: MapUseCase) {
        self.useCase = useCase
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .filterTapped(filterType):
            return .just(.setActiveFilter(filterType))

        case let .filterUpdated(type, values):
            print("MapReactor filterUpdated - type: \(type), values: \(values)")
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

        default:
            return .empty()
        }
    }


    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setActiveFilter(filterType):
            newState.activeFilterType = filterType
        case let .setLocationFilters(filters):
            newState.selectedLocationFilters = filters
            print("Updating selectedLocationFilters to: \(filters)")
        case let .setCategoryFilters(filters):
            newState.selectedCategoryFilters = filters
        case .clearLocationFilters:
            newState.selectedLocationFilters = []
        case .clearCategoryFilters: // 카테고리 필터 초기화
            newState.selectedCategoryFilters = []
        }
        return newState
    }
}

