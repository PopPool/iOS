import UIKit

import DomainInterface
import Infrastructure
import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift

final class MyPageRecentReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case changePage
        case backButtonTapped(controller: BaseViewController)
        case cellTapped(controller: BaseViewController, row: Int)
    }

    enum Mutation {
        case loadView
        case skip
        case moveToRecentScene(controller: BaseViewController)
        case moveToDetailScene(controller: BaseViewController, row: Int)
    }

    struct State {
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    private var isLoading: Bool = false
    private var totalPage: Int32 = 0
    private var currentPage: Int32 = 0
    private var size: Int32 = 100

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
    private var listSection = RecentPopUpSection(inputDataList: [])
    private var spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])

    // MARK: - init
    init(userAPIUseCase: UserAPIUseCase) {
        self.userAPIUseCase = userAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            if listSection.isEmpty {
                return userAPIUseCase.getRecentPopUp(page: currentPage, size: size, sort: nil)
                    .withUnretained(self)
                    .map { (owner, response) in
                        owner.countSection.inputDataList = [.init(count: Int(response.totalElements))]
                        owner.listSection.inputDataList = response.popUpInfoList.map {
                            .init(imagePath: $0.mainImageUrl, date: $0.endDate, title: $0.popUpStoreName, id: $0.popUpStoreId)
                        }
                        owner.totalPage = response.totalPages
                        return .loadView
                    }
            } else {
                return Observable.just(.skip)
            }
        case .changePage:
            if isLoading {
                return Observable.just(.skip)
            } else {
                if currentPage <= totalPage {
                    isLoading = true
                    currentPage += 1
                    return userAPIUseCase.getRecentPopUp(page: currentPage, size: size, sort: nil)
                        .withUnretained(self)
                        .map { (owner, response) in
                            owner.countSection.inputDataList = [.init(count: Int(response.totalElements))]
                            owner.listSection.inputDataList.append(contentsOf: response.popUpInfoList.map {
                                .init(imagePath: $0.mainImageUrl, date: $0.endDate, title: $0.popUpStoreName, id: $0.popUpStoreId)
                            })
                            return .loadView
                        }
                } else {
                    return Observable.just(.skip)
                }
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
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .skip:
            break
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .moveToDetailScene(let controller, let row):
            let nextController = DetailController()
            nextController.reactor = DetailReactor(
                popUpID: listSection.inputDataList[row].id,
                userAPIUseCase: userAPIUseCase,
                popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
                commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
            )
            controller.navigationController?.pushViewController(nextController, animated: true)
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
