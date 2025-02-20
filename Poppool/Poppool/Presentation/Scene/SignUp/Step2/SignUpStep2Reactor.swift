//
//  SignUpStep2Reactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class SignUpStep2Reactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case inputNickName(text: String?)
        case beginNickNameInput
        case endNickNameInput
        case clearButtonTapped
        case duplicatedButtonTapped
    }
    
    enum Mutation {
        case setNickNameState(text: String?)
        case setActiveState(isActive: Bool)
        case setDuplicatedSet(isDuplicated: Bool)
        case resetNickName
    }
    
    struct State {
        var nickNameState: NickNameState = .empty
        var isActiveInput: Bool = false
        var nickName: String? = nil
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    private let signUpAPIUseCase = SignUpAPIUseCaseImpl(repository: SignUpRepositoryImpl(provider: ProviderImpl()))
    private var nickName: String?
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputNickName(let text):
            return Observable.just(.setNickNameState(text: text))
        case .beginNickNameInput:
            return Observable.just(.setActiveState(isActive: true))
        case .endNickNameInput:
            return Observable.just(.setActiveState(isActive: false))
        case .duplicatedButtonTapped:
            let nickName = nickName ?? ""
            return signUpAPIUseCase.checkNickName(nickName: nickName)
                .map { isDuplicated in
                    return .setDuplicatedSet(isDuplicated: isDuplicated)
                }
        case .clearButtonTapped:
            return Observable.just(.resetNickName)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickNameState(let text):
            newState.nickName = text
            nickName = text
            newState.nickNameState = checkNickNameState(text: newState.nickName, isActive: newState.isActiveInput)
        case .setActiveState(let isActive):
            newState.isActiveInput = isActive
            newState.nickNameState = checkNickNameState(text: newState.nickName, isActive: newState.isActiveInput)
        case .setDuplicatedSet(let isDuplicated):
            newState.nickNameState = isDuplicated 
            ? newState.isActiveInput ? .duplicatedActive : .duplicated
            : newState.isActiveInput ? .validateActive : .validate
        case .resetNickName:
            newState.nickName = nil
            newState.nickNameState = checkNickNameState(text: newState.nickName, isActive: newState.isActiveInput)
        }
        return newState
    }
    
    func checkNickNameState(text: String?, isActive: Bool) -> NickNameState {
        guard let text = text else { return isActive ? .emptyActive : .empty }
        // textEmpty Check
        if text.isEmpty { return isActive ? .emptyActive : .empty }
        
        
        // textLength Check
        if text.count < 2 { return isActive ? .shortLengthActive : .shortLength }
        if text.count > 10 { return isActive ? .longLengthActive : .longLength }
        
        // kor and end Check
        let pattern = "^[가-힣a-zA-Z\\s]+$" // 허용하는 문자만 검사
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        if regex.firstMatch(in: text, options: [], range: range) == nil { return isActive ? .korAndEngActive : .korAndEng }

        
        return isActive ? .checkActive : .check
    }
}
