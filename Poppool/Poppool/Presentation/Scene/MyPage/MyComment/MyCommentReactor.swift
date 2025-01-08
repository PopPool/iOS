//
//  MyCommentReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/8/25.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class MyCommentReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
    }
    
    enum Mutation {
        case loadView
    }
    
    struct State {
        var sections: [any Sectionable] = []
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self = self else {
                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    ))
                )
            }
            return getSection()[section].getSection(section: section, env: env)
        }
    }()
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(.loadView)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return []
    }
}
