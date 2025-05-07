import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class FilterSelectReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case closeButtonTapped
        case statusSegmentChanged(index: Int)
        case sortSegmentChanged(index: Int)
        case saveButtonTapped
    }

    enum Mutation {
        case dismiss
        case changeStatus(status: PopupStatus)
        case changeSort(sort: PopupSort)
        case updateSaveButtonEnable
        case saveCurrentFilter
    }

    struct State {
        var selectedFilter: Filter
        var saveButtonIsEnable: Bool = false

        @Pulse var saveButtonTapped: Void?
        @Pulse var dismiss: Void?
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
        case .closeButtonTapped:
            return .just(.dismiss)

        case .statusSegmentChanged(let index):
            switch index == 0 {
            case true:
                return .concat([
                    .just(.changeStatus(status: .open)),
                    .just(.updateSaveButtonEnable)
                ])
            case false:
                return .concat([
                    .just(.changeStatus(status: .closed)),
                    .just(.updateSaveButtonEnable)
                ])
            }

        case .sortSegmentChanged(let index):
            switch index == 0 {
            case true:
                return .concat([
                    .just(.changeSort(sort: .newest)),
                    .just(.updateSaveButtonEnable)
                ])
            case false:
                return .concat([
                    .just(.changeSort(sort: .popularity)),
                    .just(.updateSaveButtonEnable)
                ])
            }

        case .saveButtonTapped:
            return .concat([
                .just(.saveCurrentFilter),
                .just(.dismiss)
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .dismiss:
            newState.dismiss = ()

        case .changeStatus(let status):
            newState.selectedFilter.status = status

        case .changeSort(let sort):
            newState.selectedFilter.sort = sort

        case .updateSaveButtonEnable:
            newState.saveButtonIsEnable = (newState.selectedFilter != Filter.shared)

        case .saveCurrentFilter:
            Filter.shared.status = newState.selectedFilter.status
            Filter.shared.sort = newState.selectedFilter.sort
            newState.saveButtonTapped = ()
        }

        return newState
    }
}
