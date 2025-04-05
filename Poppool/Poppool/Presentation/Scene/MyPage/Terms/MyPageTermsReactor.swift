//
//  MyPageTermsReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 2/4/25.
//

import Foundation
import ReactorKit
import RxCocoa
import RxSwift

final class MyPageTermsReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case cellTapped(indexPath: IndexPath, controller: BaseViewController)
        case backButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case moveToDetailScene(controller: BaseViewController, indexPath: IndexPath)
        case moveToRecentScene(controller: BaseViewController)
    }

    struct State {
        var sections: [any Sectionable] = []
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    private lazy var countSection = CommentListTitleSection(inputDataList: [.init(count: termsSection.dataCount)])
    private var termsSection = MyPageListSection(inputDataList: [
        .init(title: "서비스이용약관"),
        .init(title: "개인정보처리방침"),
        .init(title: "위치정보 이용약관")
    ])

    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])

    // MARK: - init
    init() {
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(.loadView)
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .cellTapped(let indexPath, let controller):
            return Observable.just(.moveToDetailScene(controller: controller, indexPath: indexPath))

        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSections()
        case .moveToDetailScene(controller: let controller, indexPath: let indexPath):
            let text = getContent(index: indexPath.row + 1)
            let nextController = TermsDetailController(title: termsSection.inputDataList[indexPath.row].title, content: text)
            controller.present(nextController, animated: true)
        case .moveToRecentScene(controller: let controller):
            controller.navigationController?.popViewController(animated: true)
        }
        return newState
    }

    func getSections() -> [any Sectionable] {
        return [
            spacing16Section,
            countSection,
            spacing16Section,
            termsSection
        ]
    }

    func getContent(index: Int) -> String {
        if let path = Bundle.main.path(forResource: "Terms", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String],
           let longText = dict["Terms\(index == 3 ? 4 : index)"] {
            return longText
        } else {
            return ""
        }
    }
}
