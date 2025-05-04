import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class FilterOptionSelectReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case changeStatus(status: PopupStatus)
        case changeSortOption(sortOption: PopupSortOption)
        case saveButtonTapped
    }

    enum Mutation {
        case changeStatus(status: PopupStatus)
        case changeSortOption(sortOption: PopupSortOption)
        case save
    }

    struct State {
        var selectedFilterOption: FilterOption
        var saveButtonIsEnable: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    private var originFilterOption: FilterOption

    // MARK: - init
    init() {
        self.initialState = State(selectedFilterOption: FilterOption.shared.copy() as! FilterOption)
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeStatus(let status):
            return Observable.just(.changeStatus(status: status))

        case .changeSortOption(let filter):
            return Observable.just(.changeSortOption(sortOption: filter))

        case .saveButtonTapped:
            return Observable.just(.save)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .changeStatus(let status):
            newState.selectedFilterOption.status = status
            newState.saveButtonIsEnable = (newState.selectedFilterOption != FilterOption.shared)

        case .changeSortOption(let sortOption):
            newState.selectedFilterOption.sortOption = sortOption
            newState.saveButtonIsEnable = (newState.selectedFilterOption != FilterOption.shared)

        case .save:
            FilterOption.shared.status = newState.selectedFilterOption.status
            FilterOption.shared.sortOption = newState.selectedFilterOption.sortOption
        }

        return newState
    }
}
