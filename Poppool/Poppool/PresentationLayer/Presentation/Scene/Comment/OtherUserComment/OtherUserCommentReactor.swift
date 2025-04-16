//
//  OtherUserCommentReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class OtherUserCommentReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case backButtonTapped(controller: BaseViewController)
        case cellTapped(controller: BaseViewController, row: Int)
    }

    enum Mutation {
        case moveToRecentScene(controller: BaseViewController)
        case loadView
        case skip
        case moveToDetailScene(controller: BaseViewController, row: Int)
    }

    struct State {
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    private let commenterID: String?
    private let userAPIUseCase: UserAPIUseCase

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
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private var countTitleSection = CommentListTitleSection(inputDataList: [])
    private var popUpSection = MyCommentedPopUpGridSection(inputDataList: [])

    // MARK: - init
    init(
        commenterID: String?,
        userAPIUseCase: UserAPIUseCase
    ) {
        self.initialState = State()
        self.commenterID = commenterID
        self.userAPIUseCase = userAPIUseCase
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return userAPIUseCase.getOtherUserCommentedPopUpList(commenterId: commenterID, commentType: "NORMAL", page: 0, size: 100, sort: nil)
                .withUnretained(self)
                .map { (owner, responseList) in
                    owner.popUpSection.inputDataList = responseList.popUpInfoList.map({ response in
                        return .init(
                            popUpID: response.popUpStoreId,
                            imageURL: response.mainImageUrl,
                            title: response.popUpStoreName,
                            content: response.desc,
                            startDate: response.startDate,
                            endDate: response.endDate
                        )
                    })
                    return .loadView
                }
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .cellTapped(let controller, let row):
            return Observable.just(.moveToDetailScene(controller: controller, row: row))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .skip:
            break
        case .moveToDetailScene(let controller, let row):
            let id = popUpSection.inputDataList[row].popUpID
            let nextController = DetailController()
            nextController.reactor = DetailReactor(
                popUpID: id,
                userAPIUseCase: userAPIUseCase
            )
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            spacing16Section,
            countTitleSection,
            spacing16Section,
            popUpSection
        ]
    }
}
