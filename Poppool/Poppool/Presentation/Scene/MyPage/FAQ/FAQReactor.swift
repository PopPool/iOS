//
//  FAQReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/13/25.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class FAQReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case dropButtonTapped(row: Int)
        case backButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case loadView
        case moveToRecentScene(controller: BaseViewController)
    }
    
    struct State {
        var sections: [any Sectionable] = []
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
    private let faqTitleSection = MyPageMyCommentTitleSection(inputDataList: [.init(title: "자주 묻는 질문")])
    private var faqSection = FAQDropdownSection(inputDataList: [
        .init(title: "회원탈퇴 후 재가입이 가능한가요?", content: "으아아아아", isOpen: false),
        .init(title: "저장한 팝업을 어디서 볼 수 있나요?", content: "으아아아아", isOpen: false),
        .init(title: "추천은 어떤 기준으로 보여지나요?", content: "모든 국민은 학문과 예술의 자유를 가진다.모든 국민은 언론·출판의 자유와 집회·결사의 자유를 가진다.헌법재판소는 법률에 저촉되지 아니하는 범위안에서 심판에 관한 절차, 내부규율과 사무처리에 관한 규칙을 제정할 수 있다.", isOpen: false)
    ])
    private let qnaTitleSection = MyPageMyCommentTitleSection(inputDataList: [.init(title: "직접 문의하기")])
    private var qnaSection = MyPageListSection(inputDataList: [
        .init(title: "메일로 문의"),
        .init(title: "메일로 문의")
    ])
    let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    let spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    let spacing48Section = SpacingSection(inputDataList: [.init(spacing: 48)])
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(.loadView)
        case .dropButtonTapped(let row):
            faqSection.inputDataList[row].isOpen.toggle()
            return Observable.just(.loadView)
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
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return [
            spacing24Section,
            faqTitleSection,
            spacing16Section,
            faqSection,
            spacing48Section,
            qnaTitleSection,
            spacing16Section,
            qnaSection
        ]
    }
}
