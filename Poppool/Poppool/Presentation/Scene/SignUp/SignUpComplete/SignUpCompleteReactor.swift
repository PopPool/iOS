//
//  SignUpCompleteReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/27/24.
//

import ReactorKit
import RxCocoa
import RxSwift

final class SignUpCompleteReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case completeButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case moveToHomeScene(controller: BaseViewController)
    }

    struct State {
        var nickName: String
        var categoryTitles: [String]
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    var isFirstResponderCase: Bool
    // MARK: - init
    init(nickName: String, categoryTitles: [String], isFirstResponderCase: Bool) {
        self.initialState = State(nickName: nickName, categoryTitles: categoryTitles)
        self.isFirstResponderCase = isFirstResponderCase
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .completeButtonTapped(let controller):
            return Observable.just(.moveToHomeScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .moveToHomeScene(let controller):
            if isFirstResponderCase {
                let homeTabbar = WaveTabBarController()
                controller.view.window?.rootViewController = homeTabbar
            } else {
                controller.dismiss(animated: true)
            }
        }
        return state
    }
}
