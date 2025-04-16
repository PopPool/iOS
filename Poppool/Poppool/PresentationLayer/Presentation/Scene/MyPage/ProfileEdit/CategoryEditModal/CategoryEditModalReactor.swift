//
//  CategoryEditModalReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/10/25.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class CategoryEditModalReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case xmarkButtonTapped(controller: BaseViewController)
        case cellTapped(row: Int)
        case saveButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case moveToRecentScene(controller: BaseViewController, isEdit: Bool)
    }

    struct State {
        var sections: [any Sectionable] = []
        var originSelectedID: [Int64]
        var saveButtonIsEnable: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    private let originSelectedID: [Int64]

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

    private var signUpUseCase = SignUpAPIUseCaseImpl(repository: SignUpRepositoryImpl(provider: ProviderImpl()))
    private var userAPIUseCase: UserAPIUseCase
    private var tagSection = TagSection(inputDataList: [])

    // MARK: - init
    init(
        selectedID: [Int64],
        userAPIUseCase: UserAPIUseCase
    ) {
        self.originSelectedID = selectedID
        self.userAPIUseCase = userAPIUseCase
        self.initialState = State(originSelectedID: selectedID)
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return signUpUseCase.fetchCategoryList()
                .withUnretained(self)
                .map { owner, categorys in
                    owner.tagSection.inputDataList = categorys.map { .init(title: $0.category, isSelected: owner.originSelectedID.contains($0.categoryId), id: $0.categoryId)}
                    return .loadView
                }
        case .xmarkButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller, isEdit: false))
        case .cellTapped(let row):
            if tagSection.inputDataList[row].isSelected {
                tagSection.inputDataList[row].isSelected.toggle()
            } else {
                if tagSection.inputDataList.filter { $0.isSelected == true }.count < 5 {
                    tagSection.inputDataList[row].isSelected.toggle()
                } else {
                    ToastMaker.createToast(message: "최대 5개까지 선택할 수 있어요")
                }
            }
            return Observable.just(.loadView)
        case .saveButtonTapped(let controller):
            var addList: [Int64] = []
            var keepList: [Int64] = []
            var deleteList: [Int64] = []
            let currentArray = tagSection.inputDataList.filter { $0.isSelected == true }.compactMap { $0.id }
            for index in currentArray {
                if originSelectedID.contains(index) {
                    keepList.append(index)
                } else {
                    addList.append(index)
                }
            }
            deleteList = originSelectedID.filter { !currentArray.contains($0) }
            return userAPIUseCase.putUserCategory(
                interestCategoriesToAdd: addList,
                interestCategoriesToDelete: deleteList,
                interestCategoriesToKeep: keepList
            )
            .andThen(Observable.just(.moveToRecentScene(controller: controller, isEdit: true)))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        let originArray = originSelectedID.sorted(by: <)
        let currentArray = tagSection.inputDataList.filter { $0.isSelected == true }.compactMap { $0.id }.sorted(by: <)
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        case .moveToRecentScene(let controller, let isEdit):
            if isEdit { ToastMaker.createToast(message: "수정사항을 반영했어요")}
            controller.dismiss(animated: true)
        }

        if currentArray.isEmpty {
            newState.saveButtonIsEnable = false
        } else {
            newState.saveButtonIsEnable = originArray != currentArray
        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [tagSection]
    }
}
