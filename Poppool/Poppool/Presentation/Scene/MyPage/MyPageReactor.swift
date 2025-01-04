//
//  MyPageReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/30/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class MyPageReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case settingButtonTapped(controller: BaseViewController)
        case loginButtonTapped(controller: BaseViewController)
        case commentCellTapped(controller: BaseViewController, row: Int)
        case commentButtonTapped(controller: BaseViewController)
        case listCellTapped(controller: BaseViewController, title: String?)
    }
    
    enum Mutation {
        case loadView
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var isLogin: Bool = false
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
    
    private var profileSection = MyPageProfileSection(inputDataList: [])
    private var commentTitleSection = MyPageMyCommentTitleSection(inputDataList: [.init(title: "내 코멘트", buttonTitle: "전체보기")])
    private var commentSection = MyPageCommentSection(inputDataList: [])
    private var normalTitleSection = MyPageMyCommentTitleSection(inputDataList: [.init(title: "일반", buttonTitle: nil)])
    private var normalSection = MyPageListSection(inputDataList: [
        .init(title: "찜한 팝업"),
        .init(title: "최근 본 팝업"),
        .init(title: "차단한 사용자 관리")
    ])
    private var infoTitleSection = MyPageMyCommentTitleSection(inputDataList: [.init(title: "정보", buttonTitle: nil)])
    private var infoSection = MyPageListSection(inputDataList: [
        .init(title: "공지사항"),
        .init(title: "고객문의"),
        .init(title: "약관"),
        .init(title: "버전정보", subTitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
    ])
    private var etcSection = MyPageListSection(inputDataList: [
        .init(title: "회원탈퇴")
    ])
    
    private var adminEtcSection = MyPageListSection(inputDataList: [
        .init(title: "회원탈퇴"),
        .init(title: "관리자 메뉴 바로가기")
    ])
    
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private let spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private let spacing28Section = SpacingSection(inputDataList: [.init(spacing: 28)])
    private let spacing16GraySection = SpacingSection(inputDataList: [.init(spacing: 16, backgroundColor: .g50)])
    private let spacing100Section = SpacingSection(inputDataList: [.init(spacing: 100)])
    
    var isLogin: Bool = false
    var isAdmin: Bool = false
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return userAPIUseCase.getMyPage()
                .withUnretained(self)
                .map { (owner, response) in
                    owner.isLogin = response.loginYn
//                    owner.isLogin = false
                    owner.isAdmin = response.adminYn
                    
                    owner.profileSection.inputDataList = [
                        .init(
                            isLogin: response.loginYn,
//                            isLogin: false,
                            profileImagePath: response.profileImageUrl,
                            nickName: response.nickname,
//                            description: response.intro
                            description: "Test Intro"
                        )
                    ]
                    owner.commentSection.inputDataList = response.myCommentedPopUpList.map  {
                        .init(popUpImagePath: $0.mainImageUrl, title: $0.popUpStoreName, popUpID: $0.popUpStoreId)
                    }
                    return .loadView
                }
        case .settingButtonTapped(let controller):
            print("settingButtonTapped")
            return Observable.just(.loadView)
        case .commentButtonTapped(let controller):
            print("commentButtonTapped")
            return Observable.just(.loadView)
        case .commentCellTapped(let controller, let row):
            print("commentCellTapped")
            return Observable.just(.loadView)
        case .loginButtonTapped(let controller):
            print("loginButtonTapped")
            return Observable.just(.loadView)
        case .listCellTapped(let controller, let title):
            print("listCellTapped")
            return Observable.just(.loadView)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
            newState.isLogin = isLogin
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return getProfileSection() + getCommentSection() + getNormalSection() + getInfoSection() + getETCSection()
    }
    
    
    func getProfileSection() -> [any Sectionable] {
        return [profileSection]
    }
    
    func getCommentSection() -> [any Sectionable] {
        if !isLogin { return [] }
        if commentSection.isEmpty {
            return []
        } else {
            return [
                commentTitleSection,
                spacing24Section,
                commentSection,
                spacing24Section
            ]
        }
    }
    
    func getNormalSection() -> [any Sectionable] {
        if isLogin {
            return [
                spacing16GraySection,
                spacing24Section,
                normalTitleSection,
                spacing16Section,
                normalSection
            ]
        } else {
            return []
        }
    }
    
    func getInfoSection() -> [any Sectionable] {
        if isLogin {
            return [
                spacing16GraySection,
                spacing24Section,
                infoTitleSection,
                spacing16Section,
                infoSection,
            ]
        } else {
            return [
                infoTitleSection,
                spacing16Section,
                infoSection,
            ]
        }
    }
    
    func getETCSection() -> [any Sectionable] {
        if isLogin {
            if isAdmin {
                return [
                    spacing16GraySection,
                    spacing28Section,
                    adminEtcSection,
                    spacing100Section
                ]
            } else {
                return [
                    spacing16GraySection,
                    spacing28Section,
                    etcSection,
                    spacing100Section
                ]
            }
        } else {
            return [spacing100Section]
        }
    }
}
