//
//  CommentSelectedReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/13/24.
//

import ReactorKit
import RxCocoa
import RxSwift

final class CommentSelectedReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case cancelButtonTapped
        case normalButtonTapped
        case instaButtonTapped
    }

    enum Mutation {
        case moveToRecentScene
        case moveToNormalScene
        case moveToInstaScene
    }

    struct State {
        var selectedType: SelectedType = .none
    }

    enum SelectedType {
        case none
        case cancel
        case normal
        case insta
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
        case .cancelButtonTapped:
            return Observable.just(.moveToRecentScene)
        case .normalButtonTapped:
            return Observable.just(.moveToNormalScene)
        case .instaButtonTapped:
            return Observable.just(.moveToInstaScene)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .moveToRecentScene:
            newState.selectedType = .cancel
        case .moveToNormalScene:
            newState.selectedType = .normal
        case .moveToInstaScene:
            newState.selectedType = .insta
        }
        return newState
    }
}
