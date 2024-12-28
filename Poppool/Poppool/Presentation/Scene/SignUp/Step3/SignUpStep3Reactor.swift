//
//  SignUpStep3Reactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class SignUpStep3Reactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case selectedTag(indexPath: IndexPath)
    }
    
    enum Mutation {
        case loadView
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var selectedCategory: [Int64] = []
        var selectedCategoryTitle: [String] = []
        var categoryIDList: [Int64] = []
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    private let signUpAPIUseCase = SignUpAPIUseCaseImpl(repository: SignUpRepositoryImpl(provider: ProviderImpl()))
    private var cetegoryIDList: [Int64] = []
    
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
    
    private var categorySection: TagSection = TagSection(inputDataList: [])
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return signUpAPIUseCase.fetchCategoryList()
                .withUnretained(self)
                .map { (owner, categorys) in
                    owner.cetegoryIDList = categorys.map { $0.categoryId }
                    owner.categorySection.inputDataList = categorys.map({ category in
                        return .init(title: category.category, isSelected: false, id: category.categoryId)
                    })
                    return .loadView
                }
        case .selectedTag(let indexPath):
            let selectedCount = categorySection.inputDataList.map { $0.isSelected }.filter { $0 == true }.count
            if selectedCount >= 5 {
                if categorySection.inputDataList[indexPath.row].isSelected {
                    categorySection.inputDataList[indexPath.row].isSelected.toggle()
                } else {
                    ToastMaker.createToast(message: "최대 5개까지 선택할 수 있어요")
                }
                
            } else {
                categorySection.inputDataList[indexPath.row].isSelected.toggle()
            }
            return Observable.just(.loadView)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
            newState.categoryIDList = cetegoryIDList
            newState.selectedCategory = categorySection.inputDataList.filter { $0.isSelected == true }.compactMap { $0.id }
            newState.selectedCategoryTitle = categorySection.inputDataList.filter { $0.isSelected == true }.compactMap { $0.title }
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return [
            categorySection
        ]
    }
}
