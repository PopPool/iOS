import UIKit

import DomainInterface
import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift

final class MyPageNoticeReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case listCellTapped(controller: BaseViewController, row: Int)
        case backButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case moveToDetailScene(controller: BaseViewController, row: Int)
        case moveToRecentScene(controller: BaseViewController)
    }

    struct State {
        var sections: [any Sectionable] = []
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
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
    private var countSection = CommentListTitleSection(inputDataList: [])
    private var listSection = NoticeListSection(inputDataList: [])
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])

    // MARK: - init
    init(userAPIUseCase: UserAPIUseCase) {
        self.userAPIUseCase = userAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return userAPIUseCase.getNoticeList()
                .withUnretained(self)
                .map { (owner, response) in
                    owner.countSection.inputDataList = [.init(count: response.noticeInfoList.count)]
                    owner.listSection.inputDataList = response.noticeInfoList.map {
                        .init(title: $0.title, date: $0.createdDateTime, noticeID: $0.id)
                    }
                    return .loadView
                }
        case .listCellTapped(let controller, let row):
            return Observable.just(.moveToDetailScene(controller: controller, row: row))
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        case .moveToDetailScene(let controller, let row):
            let nextController = MyPageNoticeDetailController()
            nextController.reactor = MyPageNoticeDetailReactor(
                noticeID: listSection.inputDataList[row].noticeID,
                userAPIUseCase: userAPIUseCase
            )
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            spacing16Section,
            countSection,
            spacing16Section,
            listSection
        ]
    }
}
