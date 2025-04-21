import DomainInterface

import ReactorKit
import RxCocoa
import RxSwift

final class MyPageNoticeDetailReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case backButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case moveToRecentScene(controller: BaseViewController)
    }

    struct State {
        var title: String?
        var date: String?
        var content: String?
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    var title: String?
    var date: String?
    var content: String?
    var noticeID: Int64

    let userAPIUseCase: UserAPIUseCase
    // MARK: - init
    init(
        noticeID: Int64,
        userAPIUseCase: UserAPIUseCase
    ) {
        self.noticeID = noticeID
        self.userAPIUseCase = userAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return userAPIUseCase.getNoticeDetail(noticeID: noticeID)
                .withUnretained(self)
                .map { (owner, response) in
                    owner.title = response.title
                    owner.date = response.createDateTime
                    owner.content = response.content
                    return .loadView
                }
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.title = title
            newState.date = date
            newState.content = content
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        }
        return newState
    }
}
