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
        case listTapped(controller: BaseViewController, row: Int)
        case backButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case loadView
        case skip
        case moveToDetailScene(controller: BaseViewController, row: Int)
        case moveToRecentScene(controller: BaseViewController)
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
    private let userAPIUseCase = UserAPIUseCaseImpl(repository: UserAPIRepositoryImpl(provider: ProviderImpl()))
    
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
    
    private var listCountSection = CommentListTitleSection(inputDataList: [])
    private var listSection = MyCommentedPopUpGridSection(inputDataList: [])
    private var spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private var spacing64Section = SpacingSection(inputDataList: [.init(spacing: 64)])
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            if listSection.isEmpty {
                return userAPIUseCase.getMyCommentedPopUp(page: 0, size: 100, sort: nil)
                    .withUnretained(self)
                    .map { (owner, response) in
                        print(response)
                        owner.listCountSection.inputDataList = [.init(count: response.popUpInfoList.count)]
                        owner.listSection.inputDataList = response.popUpInfoList.map { popupStore in
                            return .init(
                                popUpID: popupStore.popUpStoreId,
                                imageURL: nil,
                                title: popupStore.popUpStoreName,
                                content: popupStore.desc,
                                startDate: popupStore.startDate,
                                endDate: popupStore.endDate
                            )
                        }
                        return .loadView
                    }
            } else {
                return Observable.just(.skip)
            }
        case .listTapped(let controller, let row):
            return Observable.just(.moveToDetailScene(controller: controller, row: row))
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .skip:
            break
        case .moveToDetailScene(let controller, let row):
            let popUpID = listSection.inputDataList[row].popUpID
            let nextController = DetailController()
            nextController.reactor = DetailReactor(popUpID: popUpID)
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return [
            spacing16Section,
            listCountSection,
            spacing16Section,
            listSection,
            spacing64Section
        ]
    }
}
