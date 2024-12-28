//
//  CommentUserBlockReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import ReactorKit
import RxSwift
import RxCocoa

final class CommentUserBlockReactor: Reactor {
    
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
        var nickName: String?
    }
    
    enum SelectedType {
        case none
        case cancel
        case block
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
    // MARK: - init
    init(nickName: String?) {
        self.initialState = State(nickName: nickName)
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .continueButtonTapped:
            return Observable.just(.setSelectedType(type: .block))
        case .stopButtonTapped:
            return Observable.just(.setSelectedType(type: .cancel))
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
