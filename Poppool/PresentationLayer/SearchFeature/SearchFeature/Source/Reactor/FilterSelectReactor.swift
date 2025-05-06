import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class FilterSelectReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case changeStatus(status: PopupStatus)
        case changeSort(sort: PopupSort)
        case saveButtonTapped
    }

    enum Mutation {
        case changeStatus(status: PopupStatus)
        case changeSort(sort: PopupSort)
        case saveCurrentFilter
    }

    struct State {
        var selectedFilter: Filter
        var saveButtonIsEnable: Bool = false
        var isSaveButtonTapped: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    // MARK: - init
    init() {
        self.initialState = State(selectedFilter: Filter.shared.copy() as! Filter)
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeStatus(let status):
            return Observable.just(.changeStatus(status: status))

        case .changeSort(let sort):
            return Observable.just(.changeSort(sort: sort))

        case .saveButtonTapped:
            return Observable.just(.saveCurrentFilter)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .changeStatus(let status):
            newState.selectedFilter.status = status
            newState.saveButtonIsEnable = (newState.selectedFilter != Filter.shared)

        case .changeSort(let sort):
            newState.selectedFilter.sort = sort
            newState.saveButtonIsEnable = (newState.selectedFilter != Filter.shared)

        case .saveCurrentFilter:
            Filter.shared.status = newState.selectedFilter.status
            Filter.shared.sort = newState.selectedFilter.sort
            newState.isSaveButtonTapped = true
        }

        return newState
    }
}
