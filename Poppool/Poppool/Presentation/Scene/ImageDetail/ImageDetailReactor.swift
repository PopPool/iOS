//
//  ImageDetailReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import ReactorKit
import RxCocoa
import RxSwift

final class ImageDetailReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case backButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case moveToRecentScene(controller: BaseViewController)
    }

    struct State {
        var imagePath: String?
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    // MARK: - init
    init(imagePath: String?) {
        self.initialState = State(imagePath: imagePath)
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .moveToRecentScene(let controller):
            controller.dismiss(animated: true)
        }
        return state
    }
}
