//
//  SignUpStep1Reactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class SignUpStep1Reactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case totalButtonTapped
        case termsButtonTapped(index: Int)
        case termsRightButtonTapped(index: Int, controller: BaseViewController)
    }
    
    enum Mutation {
        case setTotalSelected
        case setSelectedIndex(index: Int)
        case moveToTermsDetailScene(index: Int, controller: BaseViewController)
    }
    
    struct State {
        var selectedIndex: [Int] = []
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
        case .totalButtonTapped:
            return Observable.just(.setTotalSelected)
        case .termsButtonTapped(let index):
            return Observable.just(.setSelectedIndex(index: index))
        case .termsRightButtonTapped(let index, let controller):
            return Observable.just(.moveToTermsDetailScene(index: index, controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setTotalSelected:
            if newState.selectedIndex.count == 4 {
                newState.selectedIndex = []
            } else {
                newState.selectedIndex = [1, 2, 3, 4]
            }
        case .setSelectedIndex(let index):
            if newState.selectedIndex.contains(index) {
                if let targetIndex = newState.selectedIndex.firstIndex(of: index) {
                    newState.selectedIndex.remove(at: targetIndex)
                }
            } else {
                newState.selectedIndex.append(index)
            }
        case .moveToTermsDetailScene(let index, let controller):
            let title = getTitle(index: index)
            let content = getContent(index: index)
            controller.present(TermsDetailController(title: title, content: content), animated: true)
        }
        return newState
    }
    
    func getTitle(index: Int) -> String {
        if index == 1 {
            return "[필수] 이용약관"
        } else if index == 2 {
            return "[필수] 개인정보 수집 및 이용"
        } else {
            return "[선택] 위치정보 이용약관"
        }
    }
    
    func getContent(index: Int) -> String {
        if let path = Bundle.main.path(forResource: "Terms", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String],
           let longText = dict["Terms\(index)"] {
            return longText
        } else {
            return ""
        }
    }
}
