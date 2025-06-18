
import Foundation
import ReactorKit

final class AdminBottomSheetReactor: Reactor {
    enum Action {
        case segmentChanged(Int)
        case resetFilters
        case toggleStatusOption(String)
        case toggleCategoryOption(String)
    }

    enum Mutation {
        case setActiveSegment(Int)
        case resetFilters
        case updateStatusOptions(Set<String>)
        case updateCategoryOptions(Set<String>)
    }

    struct State {
        var activeSegment: Int = 0
        var selectedStatusOptions: Set<String> = []
        var selectedCategoryOptions: Set<String> = []

        let statusOptions = ["전체", "운영", "종료"]
        let categoryOptions = ["게임", "라이프스타일", "반려동물", "뷰티", "스포츠", "애니메이션",
                             "엔터테이먼트", "여행", "예술", "음식/요리", "키즈", "패션"]

        var isSaveEnabled: Bool {
            return !selectedStatusOptions.isEmpty || !selectedCategoryOptions.isEmpty
        }
    }

    let initialState: State

    init() {
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .segmentChanged(index):
            return .just(.setActiveSegment(index))

        case .resetFilters:
            return .just(.resetFilters)

        case let .toggleStatusOption(option):
            var newOptions = currentState.selectedStatusOptions
            if option == "전체" {
                newOptions = newOptions.contains(option) ? [] : ["전체"]
            } else {
                if newOptions.contains(option) {
                    newOptions.remove(option)
                } else {
                    newOptions.remove("전체")
                    newOptions.insert(option)
                }
            }
            return .just(.updateStatusOptions(newOptions))

        case let .toggleCategoryOption(option):
            var newOptions = currentState.selectedCategoryOptions
            if newOptions.contains(option) {
                newOptions.remove(option)
            } else {
                newOptions.insert(option)
            }
            return .just(.updateCategoryOptions(newOptions))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setActiveSegment(index):
            newState.activeSegment = index

        case .resetFilters:
            newState.selectedStatusOptions.removeAll()
            newState.selectedCategoryOptions.removeAll()

        case let .updateStatusOptions(options):
            newState.selectedStatusOptions = options

        case let .updateCategoryOptions(options):
            newState.selectedCategoryOptions = options
        }

        return newState
    }
}
