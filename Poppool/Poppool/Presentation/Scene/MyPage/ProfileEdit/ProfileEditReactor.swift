//
//  ProfileEditReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/4/25.
//

import ReactorKit
import RxSwift
import RxCocoa

final class ProfileEditReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
    }
    
    enum Mutation {
    }
    
    struct State {
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        }
        return newState
    }
}
