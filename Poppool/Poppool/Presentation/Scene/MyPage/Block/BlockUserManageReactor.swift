//
//  BlockUserManageReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class BlockUserManageReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case blockButtonTapped(row: Int)
        case backButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case moveToRecentScene(controller: BaseViewController)
    }

    struct State {
        var sections: [any Sectionable] = []
        var isEmptyList: Bool = true
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

    private var countSection = CommentListTitleSection(inputDataList: [])
    private var listSection = BlockUserListSection(inputDataList: [])
    private var spcing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])

    // MARK: - init
    init() {
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return userAPIUseCase.getBlockUserList(page: 0, size: 999, sort: nil)
                .withUnretained(self)
                .map { (owner, response) in
                    owner.countSection.inputDataList = [.init(count: Int(response.totalElements), unit: "명")]
                    owner.listSection.inputDataList = response.blockedUserInfoList.map { .init(profileImagePath: $0.profileImageUrl, nickName: $0.nickname, userID: $0.userId, isBlocked: true )}
                    return .loadView
                }
        case .blockButtonTapped(let row):
            let target = listSection.inputDataList[row]
            listSection.inputDataList[row].isBlocked.toggle()
            if target.isBlocked {
                ToastMaker.createToast(message: "차단을 해제했어요")
                return userAPIUseCase.deleteUserBlock(blockedUserId: target.userID)
                    .andThen(Observable.just(.loadView))
            } else {
                ToastMaker.createToast(message: "\(target.nickName ?? "?")님을 차단했어요")
                return userAPIUseCase.postUserBlock(blockedUserId: target.userID)
                    .andThen(Observable.just(.loadView))
            }
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        }
        newState.isEmptyList = listSection.isEmpty
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            spcing16Section,
            countSection,
            spcing16Section,
            listSection
        ]
    }
}
