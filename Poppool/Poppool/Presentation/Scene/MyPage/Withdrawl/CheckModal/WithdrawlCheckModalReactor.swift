//
//  WithdrawlCheckModalReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/6/25.
//

import ReactorKit
import RxCocoa
import RxSwift

final class WithdrawlCheckModalReactor: Reactor {

    enum ModalState {
        case none
        case cancel
        case apply
    }

    // MARK: - Reactor
    enum Action {
        case cancelButtonTapped
        case appleyButtonTapped
    }

    enum Mutation {
        case setModalState(state: ModalState)
    }

    struct State {
        var state: ModalState = .none
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    // MARK: - init
    init() {
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .appleyButtonTapped:
            return Observable.just(.setModalState(state: .apply))
        case .cancelButtonTapped:
            return Observable.just(.setModalState(state: .cancel))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setModalState(let state):
            newState.state = state
        }
        return newState
    }
}
