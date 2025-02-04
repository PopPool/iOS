//
//  CommentMyMenuReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 2/1/25.
//

import ReactorKit
import RxSwift
import RxCocoa

final class CommentMyMenuReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case cancelButtonTapped
        case removeButtonTapped
        case editButtonTapped
    }
    
    enum Mutation {
        case moveToRecentScene
        case setRemoveType
        case setEditType
    }
    
    struct State {
        var selectedType: SelectedType = .none
    }
    
    enum SelectedType {
        case none
        case cancel
        case remove
        case edit
    }
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
    // MARK: - init
    init(nickName: String?) {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cancelButtonTapped:
            return Observable.just(.moveToRecentScene)
        case .removeButtonTapped:
            return Observable.just(.setRemoveType)
        case .editButtonTapped:
            return Observable.just(.setEditType)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .moveToRecentScene:
            newState.selectedType = .cancel
        case .setRemoveType:
            newState.selectedType = .remove
        case .setEditType:
            newState.selectedType = .edit
        }
        return newState
    }
}
