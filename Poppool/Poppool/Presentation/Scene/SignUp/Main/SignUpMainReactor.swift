//
//  SignUpMainReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import ReactorKit
import RxSwift
import RxCocoa

final class SignUpMainReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case cancelButtonTapped(controller: BaseTabmanController)
        case backButtonTapped(controller: BaseTabmanController, currentIndex: Int)
        case step1ButtonTapped(controller: BaseTabmanController, currentIndex: Int)
        case step2ButtonTapped(controller: BaseTabmanController, currentIndex: Int)
        case step3ButtonTapped(controller: BaseTabmanController, currentIndex: Int)
        case step3SkipButtonTapped(controller: BaseTabmanController, currentIndex: Int)
        case step4ButtonTapped(controller: BaseTabmanController)
        case step4SkipButtonTapped(controller: BaseTabmanController)
        case changeTerms(isMarketingAgree: Bool)
        case changeNickName(nickName: String?)
        case changeCategory(categorys: [Int64], categoryTitles: [String], categoryIDList: [Int64])
        case changeGender(gender: String?)
        case changeAge(age: Int?)
    }
    
    enum Mutation {
        case moveToLoginScene(controller: BaseTabmanController)
        case increasePageIndex(controller: BaseTabmanController, currentIndex: Int)
        case decreasePageIndex(controller: BaseTabmanController, currentIndex: Int)
        case skipStep3(controller: BaseTabmanController, currentIndex: Int)
        case skipStep4(controller: BaseTabmanController)
        case moveToCompleteScene(controller: BaseTabmanController)
        case setTerms(isMarketingAgree: Bool)
        case setNickName(nickName: String?)
        case setCategory(categorys: [Int64], categoryTitles: [String], categoryIDList: [Int64])
        case setGender(gender: String?)
        case setAge(age: Int?)
    }
    
    struct State {
        var currentIndex: Int = 0
        var isMarketingAgree: Bool = false
        var nickName: String?
        var categorys: [Int64] = []
        var categoryTitles: [String] = []
        var gender: String? = "선택안함"
        var categoryIDList: [Int64] = []
        var age: Int?
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
    private var authrizationCode: String?
    
    private let signUpAPIUseCase = SignUpAPIUseCaseImpl(repository: SignUpRepositoryImpl(provider: ProviderImpl()))
    private let userDefaultService = UserDefaultService()
    var isFirstResponderCase: Bool
    
    // MARK: - init
    init(isFirstResponderCase: Bool, authrizationCode: String?) {
        self.initialState = State()
        self.authrizationCode = authrizationCode
        self.isFirstResponderCase = isFirstResponderCase
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeTerms(let isMarketingAgree):
            return Observable.just(.setTerms(isMarketingAgree: isMarketingAgree))
        case .changeNickName(let nickName):
            return Observable.just(.setNickName(nickName: nickName))
        case .changeCategory(let categorys, let titles, let categoryIDList):
            return Observable.just(.setCategory(categorys: categorys, categoryTitles: titles, categoryIDList: categoryIDList))
        case .changeGender(let gender):
            return Observable.just(.setGender(gender: gender))
        case .changeAge(let age):
            return Observable.just(.setAge(age: age))
        case .cancelButtonTapped(let controller):
            return Observable.just(.moveToLoginScene(controller: controller))
        case .backButtonTapped(let controller, let currentIndex):
            return Observable.just(.decreasePageIndex(controller: controller, currentIndex: currentIndex))
        case .step1ButtonTapped(let controller, let currentIndex):
            return Observable.just(.increasePageIndex(controller: controller, currentIndex: currentIndex))
        case .step2ButtonTapped(let controller, let currentIndex):
            return Observable.just(.increasePageIndex(controller: controller, currentIndex: currentIndex))
        case .step3ButtonTapped(let controller, let currentIndex):
            return Observable.just(.increasePageIndex(controller: controller, currentIndex: currentIndex))
        case .step3SkipButtonTapped(let controller, let currentIndex):
            return Observable.just(.skipStep3(controller: controller, currentIndex: currentIndex))
        case .step4ButtonTapped(let controller):
            return Observable.just(.moveToCompleteScene(controller: controller))
        case .step4SkipButtonTapped(let controller):
            return Observable.concat([
                Observable.just(.skipStep4(controller: controller)),
                Observable.just(.moveToCompleteScene(controller: controller))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .moveToLoginScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .increasePageIndex(let controller, let currentIndex):
            newState.currentIndex = currentIndex + 1
            controller.scrollToPage(.at(index: currentIndex + 1), animated: false)
        case .decreasePageIndex(let controller, let currentIndex):
            newState.currentIndex = currentIndex - 1
            controller.scrollToPage(.at(index: currentIndex - 1), animated: false)
        case .moveToCompleteScene(let controller):
            guard let socialType = userDefaultService.fetch(key: "socialType"),
                  let nickName = newState.nickName,
                  let gender = newState.gender else { return newState }
            
            signUpAPIUseCase.trySignUp(
                nickName: nickName,
                gender: gender,
                age: Int32(newState.age ?? 30),
                socialEmail: "",
                socialType: socialType,
                interests: newState.categorys,
                appleAuthorizationCode: authrizationCode
            )
            .subscribe { [weak self, weak controller] in
                guard let self = self else { return }
                let completeController = SignUpCompleteController()
                completeController.reactor = SignUpCompleteReactor(
                    nickName: nickName,
                    categoryTitles: newState.categoryTitles,
                    isFirstResponderCase: self.isFirstResponderCase
                )
                controller?.navigationController?.pushViewController(completeController, animated: true)
            } onError: { error in
                ToastMaker.createToast(message: "회원가입 실패:\(error.localizedDescription)")
            }
            .disposed(by: disposeBag)
            
        case .skipStep3(let controller, let currentIndex):
            if newState.categoryIDList.count >= 5 {
                newState.categorys = Array(newState.categoryIDList.shuffled().prefix(5))
            }
            newState.currentIndex = currentIndex + 1
            controller.scrollToPage(.at(index: currentIndex + 1), animated: false)
        case .skipStep4(let controller):
            newState.age = nil
            newState.gender = "선택안함"
        case .setTerms(let isMarketingAgree):
            newState.isMarketingAgree = isMarketingAgree
        case .setNickName(let nickName):
            newState.nickName = nickName
        case .setCategory(let categorys, let titles, let categoryIDList):
            newState.categoryIDList = categoryIDList
            newState.categorys = categorys
            newState.categoryTitles = titles
        case .setGender(let gender):
            newState.gender = gender
        case .setAge(let age):
            newState.age = age
        }
        return newState
    }
}
