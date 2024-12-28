//
//  SearchSortedReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/6/24.
//

import ReactorKit
import RxSwift
import RxCocoa

final class SearchSortedReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case closeButtonTapped(controller: BaseViewController)
        case changeFilterIndex(index: Int)
        case changeSortedIndex(index: Int)
        case saveButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case moveToRecentScene(controller: BaseViewController)
        case loadView
        case save(controller: BaseViewController)
    }
    
    struct State {
        var filterIndex: Int
        var sortedIndex: Int
        var saveButtonIsEnable: Bool = false
        var isSave: Bool = false
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    var originFilterIndex: Int
    var originSortedIndex: Int
    private var selectedFilterIndex: Int
    private var selectedSortedIndex: Int
    
    // MARK: - init
    init(filterIndex: Int, sortedIndex: Int) {
        self.initialState = State(filterIndex: filterIndex, sortedIndex: sortedIndex)
        self.originFilterIndex = filterIndex
        self.originSortedIndex = sortedIndex
        self.selectedFilterIndex = filterIndex
        self.selectedSortedIndex = sortedIndex
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .closeButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .changeFilterIndex(let index):
            selectedFilterIndex = index
            return Observable.just(.loadView)
        case .changeSortedIndex(let index):
            selectedSortedIndex = index
            return Observable.just(.loadView)
        case .saveButtonTapped(let controller):
            return Observable.just(.save(controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .moveToRecentScene(let controller):
            controller.dismiss(animated: true)
        case .loadView:
            newState.filterIndex = selectedFilterIndex
            newState.sortedIndex = selectedSortedIndex
            
            if selectedFilterIndex != originFilterIndex  || selectedSortedIndex != originSortedIndex {
                newState.saveButtonIsEnable = true
            } else {
                newState.saveButtonIsEnable = false
            }
        case .save(let controller):
            newState.isSave = true
            controller.dismiss(animated: true)
        }
        return newState
    }
}
