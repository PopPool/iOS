import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift

final class BookMarkPopUpViewTypeModalReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case selectedSegmentControl(row: Int)
        case saveButtonTapped(controller: BaseViewController)
        case xmarkButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case setSelectedIndex(row: Int)
        case dismissScene(controller: BaseViewController, isSave: Bool)
    }

    struct State {
        var isSetView: Bool = false
        var originSortedCode: String
        var currentSortedCode: String?
        var saveButtonIsEnabled: Bool = false
        var isSave: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    // MARK: - init
    init(sortedCode: String) {
        self.initialState = State(originSortedCode: sortedCode)
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(.loadView)
        case .selectedSegmentControl(let row):
            return Observable.just(.setSelectedIndex(row: row))
        case .saveButtonTapped(let controller):
            return Observable.just(.dismissScene(controller: controller, isSave: true))
        case .xmarkButtonTapped(let controller):
            return Observable.just(.dismissScene(controller: controller, isSave: false))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isSetView = false
        switch mutation {
        case .loadView:
            newState.isSetView = true
        case .setSelectedIndex(let row):
            let currentSelectedRow = row == 0 ? "크게보기" : "모아서보기"
            newState.currentSortedCode = currentSelectedRow
            if newState.originSortedCode == currentSelectedRow {
                newState.saveButtonIsEnabled = false
            } else {
                newState.saveButtonIsEnabled = true
            }
        case .dismissScene(let controller, let isSave):
            newState.isSave = isSave
            controller.dismiss(animated: true)
        }
        return newState
    }
}
