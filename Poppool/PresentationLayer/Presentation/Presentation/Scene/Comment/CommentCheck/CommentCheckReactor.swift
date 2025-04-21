//
//  CommentCheckReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import ReactorKit
import RxCocoa
import RxSwift

final class CommentCheckReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case continueButtonTapped
        case stopButtonTapped
    }

    enum Mutation {
        case setSelectedType(type: SelectedType)
    }

    struct State {
        var selectedType: SelectedType = .none
    }

    enum SelectedType {
        case none
        case continues
        case stop
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
        case .continueButtonTapped:
            return Observable.just(.setSelectedType(type: .continues))
        case .stopButtonTapped:
            return Observable.just(.setSelectedType(type: .stop))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSelectedType(let type):
            newState.selectedType = type
        }
        return newState
    }
}
