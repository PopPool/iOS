import UIKit

import DomainInterface
import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift

final class InfoEditModalReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case xmarkButtonTapped(controller: BaseViewController)
        case ageButtonTapped(controller: BaseViewController)
        case changeGender(index: Int)
        case changeAge(age: Int32)
        case saveButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case setGender(index: Int)
        case setAge(age: Int32)
        case moveToAgeSelectedScene(controller: BaseViewController)
        case moveToRecentScene(controller: BaseViewController, isEdit: Bool)
    }

    struct State {
        var age: Int32
        var gender: String?
        var isLoadView: Bool = true
        var saveButtonEnable: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    var originAge: Int32
    var originGender: String?
    var currentAge: Int32 = 0
    var currentGender: String?

    private let userAPIUseCase: UserAPIUseCase
    // MARK: - init
    init(
        age: Int32,
        gender: String?,
        userAPIUseCase: UserAPIUseCase
    ) {
        self.originAge = age
        self.originGender = gender
        self.userAPIUseCase = userAPIUseCase
        self.initialState = State(age: age, gender: gender)
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(.loadView)
        case .ageButtonTapped(let controller):
            return Observable.just(.moveToAgeSelectedScene(controller: controller))
        case .xmarkButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller, isEdit: false))
        case .changeGender(let index):
            return Observable.just(.setGender(index: index))
        case .changeAge(let age):
            return Observable.just(.setAge(age: age))
        case .saveButtonTapped(let controller):
            return userAPIUseCase.putUserTailoredInfo(gender: currentGender, age: currentAge)
                .andThen(Observable.just(.moveToRecentScene(controller: controller, isEdit: true)))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isLoadView = false
        switch mutation {
        case .loadView:
            break
        case .moveToAgeSelectedScene(let controller):
            let nextController = AgeSelectedController()
            nextController.reactor = AgeSelectedReactor(age: Int(newState.age))
            controller.presentPanModal(nextController)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                nextController.reactor?.state
                    .map({ state in
                        let age = state.selectedAge ?? 30
                        return Action.changeAge(age: Int32(age))
                    })
                    .bind(to: action)
                    .disposed(by: nextController.disposeBag)
            }

        case .moveToRecentScene(let controller, let isEdit):
            if isEdit { ToastMaker.createToast(message: "수정사항을 반영했어요") }
            controller.dismiss(animated: true)
        case .setGender(let index):
            let gender = index == 0 ? "남성" : index == 1 ? "여성" : "선택안함"
            newState.gender = gender
        case .setAge(let age):
            newState.age = age
        }

        if newState.gender == originGender && newState.age == originAge {
            newState.saveButtonEnable = false
        } else {
            newState.saveButtonEnable = true
        }
        currentAge = newState.age
        currentGender = newState.gender
        return newState
    }
}
