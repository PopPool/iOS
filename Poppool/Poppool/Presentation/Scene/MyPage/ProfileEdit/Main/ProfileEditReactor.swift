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
        case viewWillAppear
        case categoryButtonTapped(controller: BaseViewController)
        case infoButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case loadView
        case moveToInfoEditScene(controller: BaseViewController)
        case moveToCategoryEditScene(controller: BaseViewController)
    }
    
    struct State {
        var isLoadView: Bool = false
        var originProfileData: GetMyProfileResponse?
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    var originProfileData: GetMyProfileResponse?
    
    private let userAPIUseCase = UserAPIUseCaseImpl(repository: UserAPIRepositoryImpl(provider: ProviderImpl()))
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return userAPIUseCase.getMyProfile()
                .withUnretained(self)
                .map { (owner, response) in
                    owner.originProfileData = response
                    return .loadView
                }
        case .categoryButtonTapped(let controller):
            return Observable.just(.moveToCategoryEditScene(controller: controller))
        case .infoButtonTapped(let controller):
            return Observable.just(.moveToInfoEditScene(controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isLoadView = false
        switch mutation {
        case .loadView:
            newState.isLoadView = true
            newState.originProfileData = originProfileData
        case .moveToCategoryEditScene(let controller):
            let nextController = CategoryEditModalController()
            nextController.reactor = CategoryEditModalReactor(selectedID: newState.originProfileData?.interestCategoryList.map { $0.categoryId } ?? [])
            controller.presentPanModal(nextController)
        case .moveToInfoEditScene(let controller):
            let nextController = InfoEditModalController()
            nextController.reactor = InfoEditModalReactor(age: originProfileData?.age ?? 0, gender: originProfileData?.gender)
            controller.presentPanModal(nextController)
        }
        return newState
    }
}
