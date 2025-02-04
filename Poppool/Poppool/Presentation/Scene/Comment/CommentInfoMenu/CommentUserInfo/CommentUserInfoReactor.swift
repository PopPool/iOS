//
//  CommentUserInfoReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import ReactorKit
import RxSwift
import RxCocoa

final class CommentUserInfoReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case cancelButtonTapped
        case normalButtonTapped
        case instaButtonTapped
    }
    
    enum Mutation {
        case moveToRecentScene
        case moveToCommentScene
        case moveToBlockScene
    }
    
    struct State {
        var selectedType: SelectedType = .none
        var nickName: String?
    }
    
    enum SelectedType {
        case none
        case cancel
        case normal
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
        case .cancelButtonTapped:
            return Observable.just(.moveToRecentScene)
        case .normalButtonTapped:
            return Observable.just(.moveToCommentScene)
        case .instaButtonTapped:
            return Observable.just(.moveToBlockScene)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .moveToRecentScene:
            newState.selectedType = .cancel
        case .moveToCommentScene:
            newState.selectedType = .normal
        case .moveToBlockScene:
            newState.selectedType = .block
        }
        return newState
    }
}
