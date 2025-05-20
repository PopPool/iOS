import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift

final class AgeSelectedReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case cancelButtonTapped(controller: BaseViewController)
        case completeButtonTapped(selectedAge: Int, controller: BaseViewController)
    }

    enum Mutation {
        case setSelectedAge(selectedAge: Int, controller: BaseViewController)
        case moveToRecentScene(controller: BaseViewController)
    }

    struct State {
        var selectedAge: Int?
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    // MARK: - init
    init(age: Int?) {
        self.initialState = State(selectedAge: age)
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cancelButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .completeButtonTapped(let selectedAge, let controller ):
            return Observable.just(.setSelectedAge(selectedAge: selectedAge, controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .moveToRecentScene(let controller):
            controller.dismiss(animated: true)
        case .setSelectedAge(let selectedAge, let controller):
            newState.selectedAge = selectedAge
            controller.dismiss(animated: true)
        }
        return newState
    }
}
