import UIKit

import DesignSystem
import DomainInterface
import Infrastructure

import ReactorKit
import RxCocoa
import RxSwift

final class WithdrawlReasonReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case cellTapped(row: Int)
        case backButtonTapped(controller: BaseViewController)
        case etcTextInput(text: String?)
        case skipButtonTapped(controller: BaseViewController)
        case checkButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case moveToRecentScene(controller: BaseViewController)
        case none
        case moveToCompleteScene(controller: BaseViewController)
    }

    struct State {
        var sections: [any Sectionable] = []
        var buttonIsEnabled: Bool = false
        var isReloadView: Bool = false
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

    private var reasonSection = WithdrawlCheckSection(inputDataList: [])
    private var spacing156Section = SpacingSection(inputDataList: [.init(spacing: 156)])
    private let userAPIUseCase: UserAPIUseCase
    @Dependency private var keyChainService: KeyChainService
    private let userDefaultService = UserDefaultService()
    // MARK: - init
    init(userAPIUseCase: UserAPIUseCase) {
        self.userAPIUseCase = userAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return userAPIUseCase.getWithdrawlList()
                .withUnretained(self)
                .map { (owner, response) in
                    owner.reasonSection.inputDataList = response.withDrawlSurveyList.map {
                        .init(isSelected: false, title: $0.survey, id: $0.id)
                    }
                    return .loadView
                }
        case .cellTapped(let row):
            reasonSection.inputDataList[row].isSelected.toggle()
            return Observable.just(.loadView)
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .etcTextInput(let text):
            if let targetIndex = reasonSection.inputDataList.compactMap({ $0.title }).firstIndex(of: "기타") {
                reasonSection.inputDataList[targetIndex].text = text
            }
            return Observable.just(.none)
        case .skipButtonTapped(let controller):
            return userAPIUseCase.postWithdrawl(surveyList: [])
                .andThen(Observable.just(.moveToCompleteScene(controller: controller)))
        case .checkButtonTapped(let controller):
            let reasonList = reasonSection.inputDataList.filter { $0.isSelected == true }
            return userAPIUseCase.postWithdrawl(surveyList: reasonList.map { .init(id: $0.id, survey: $0.title)})
                .andThen(Observable.just(.moveToCompleteScene(controller: controller)))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .none:
            break
        case .moveToCompleteScene(let controller):
            keyChainService.deleteToken(type: .accessToken)
            keyChainService.deleteToken(type: .refreshToken)
            userDefaultService.delete(key: "lastLogin")
            userDefaultService.delete(key: "searchList")
            let nextController = WithdrawlCompleteController()
            nextController.mainView.checkButton.rx.tap
                .withUnretained(nextController)
                .subscribe { (nextController, _) in
                    if let navigationController = nextController.navigationController {
                        let targetViewController = navigationController.viewControllers[navigationController.viewControllers.count - 3]
                        navigationController.popToViewController(targetViewController, animated: true)
                    }
                }
                .disposed(by: disposeBag)
            controller.navigationController?.pushViewController(nextController, animated: true)
        }

        let isEmpty = reasonSection.inputDataList.filter { $0.isSelected == true }.isEmpty

        if let etc = reasonSection.inputDataList.filter({ $0.title == "기타" }).first {
            if etc.isSelected {
                if etc.text?.isEmpty ?? true {
                    newState.buttonIsEnabled = false
                } else {
                    newState.buttonIsEnabled = true
                }
            } else {
                newState.buttonIsEnabled = !isEmpty
            }
        } else {
            newState.buttonIsEnabled = !isEmpty
        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            reasonSection,
            spacing156Section
        ]
    }
}
