//
//  SearchCategoryReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/6/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SearchCategoryReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case closeButtonTapped(controller: BaseViewController)
        case saveButtonTapped(controller: BaseViewController)
        case resetButtonTapped(controller: BaseViewController)
        case cellTapped(indexPath: IndexPath)
    }

    enum Mutation {
        case moveToRecentScene(controller: BaseViewController)
        case loadView
        case save(controller: BaseViewController)
        case reset(controller: BaseViewController)
    }

    struct State {
        var sections: [any Sectionable] = []
        var categoryIDList: [Int64] = []
        var categoryTitleList: [String?] = []
        var saveButtonIsEnable: Bool = false
        var isSave: Bool = false
        var isReset: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    var originCategoryList: [Int64]
    private let signUpAPIUseCase = SignUpAPIUseCaseImpl(repository: SignUpRepositoryImpl(provider: ProviderImpl()))
    private var tagSection = TagSection(inputDataList: [])
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
    init(originCategoryList: [Int64]) {
        self.initialState = State()
        self.originCategoryList = originCategoryList
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return signUpAPIUseCase.fetchCategoryList()
                .withUnretained(self)
                .map { (owner, response) in
                    owner.tagSection.inputDataList = response.map {
                        let isSelected = owner.originCategoryList.contains($0.categoryId)
                        return .init(title: $0.category, isSelected: isSelected, id: $0.categoryId)
                    }
                    return .loadView
                }
        case .closeButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .saveButtonTapped(let controller):
            return Observable.just(.save(controller: controller))
        case .cellTapped(let indexPath):
            tagSection.inputDataList[indexPath.row].isSelected.toggle()
            return Observable.just(.loadView)
        case .resetButtonTapped(let controller):
            return Observable.just(.reset(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .moveToRecentScene(let controller):
            controller.dismiss(animated: true)
        case .loadView:
            newState.sections = getSection()
            let selectedList = tagSection.inputDataList.filter { $0.isSelected }.compactMap { $0.id }.sorted(by: <)
            let originList = originCategoryList.sorted(by: <)
            newState.saveButtonIsEnable = selectedList != originList
            newState.categoryIDList = selectedList
            newState.categoryTitleList = tagSection.inputDataList.filter { $0.isSelected }.map { $0.title }
        case .save(let controller):
            newState.isSave = true
            controller.dismiss(animated: true)
        case .reset(let controller):
            newState.isReset = true
            controller.dismiss(animated: true)
        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            tagSection
        ]
    }
}
