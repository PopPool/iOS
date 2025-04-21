//
//  SignUpStep4Reactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import ReactorKit
import RxCocoa
import RxSwift

final class SignUpStep4Reactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case selectedGender(index: Int)
        case ageSelectedButtonTapped(controller: BaseViewController)
        case ageSelected(age: Int?)
    }

    enum Mutation {
        case setGender(index: Int)
        case setAge(age: Int?)
        case moveToAgeSelectedScene(controller: BaseViewController)
    }

    struct State {
        var selectedGenderIndex: Int = 2
        var age: Int?
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
        case .ageSelected(let age):
            return Observable.just(.setAge(age: age))
        case .selectedGender(let index):
            return Observable.just(.setGender(index: index))
        case .ageSelectedButtonTapped(let controller):
            return Observable.just(.moveToAgeSelectedScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAge(let age):
            newState.age = age
        case .moveToAgeSelectedScene(let controller):
            let ageSelectedController = AgeSelectedController()
            ageSelectedController.reactor = AgeSelectedReactor(age: state.age)
            controller.presentPanModal(ageSelectedController)
            ageSelectedController.reactor?.state
                .observe(on: MainScheduler.asyncInstance)
                .map { Action.ageSelected(age: $0.selectedAge) }
                .bind(to: action)
                .disposed(by: disposeBag)
        case .setGender(let index):
            newState.selectedGenderIndex = index
        }
        return newState
    }
}
