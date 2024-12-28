//
//  SearchMainReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/7/24.
//

import ReactorKit
import RxSwift
import RxCocoa

final class SearchMainReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case returnSearchKeyWord(text: String?)
    }
    
    enum Mutation {
        case setSearchKeyWord(text: String?)
    }
    
    struct State {
        var searchKeyword: String?
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
        case .returnSearchKeyWord(let text):
            return Observable.just(.setSearchKeyWord(text: text))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSearchKeyWord(let text):
            newState.searchKeyword = text
        }
        return newState
    }
}
