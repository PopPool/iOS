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
        case logoutButtonTapped
    }
    
    enum Mutation {
        case loadView
        case moveToProfileEditScene(controller: BaseViewController)
        case logout
        case moveToDetailScene(controller: BaseViewController, title: String?)
        case moveToLoginScene(controller: BaseViewController)
        case moveToMyCommentScene(controller: BaseViewController)
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
    
    private var logoutSection = MyPageLogoutSection(inputDataList: [.init()])
    
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
                    owner.isAdmin = response.adminYn
                    
                    owner.profileSection.inputDataList = [
                        .init(
                            isLogin: response.loginYn,
                            profileImagePath: response.profileImageUrl,
                            nickName: response.nickname,
                            description: response.intro
                        )
                    ]
                    owner.commentSection.inputDataList = response.myCommentedPopUpList.map  {
                        .init(popUpImagePath: $0.mainImageUrl, title: $0.popUpStoreName, popUpID: $0.popUpStoreId)
                    }
                    return .loadView
                }
        case .settingButtonTapped(let controller):
            return Observable.just(.moveToProfileEditScene(controller: controller))
        case .commentButtonTapped(let controller):
            return Observable.just(.moveToMyCommentScene(controller: controller))
        case .commentCellTapped(let controller, let row):
            return Observable.just(.loadView)
        case .loginButtonTapped(let controller):
            return Observable.just(.moveToLoginScene(controller: controller))
        case .listCellTapped(let controller, let title):
            return Observable.just(.moveToDetailScene(controller: controller, title: title))
        case .logoutButtonTapped:
            return userAPIUseCase.postLogout()
                .andThen(Observable.just(.logout))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
            newState.isLogin = isLogin
        case .moveToProfileEditScene(let controller):
            let nextController = ProfileEditController()
            nextController.reactor = ProfileEditReactor()
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .logout:
            let service = KeyChainService()
            let _ = service.deleteToken(type: .accessToken)
            let _ = service.deleteToken(type: .refreshToken)
            ToastMaker.createToast(message: "로그아웃 되었어요")
            DispatchQueue.main.async { [weak self] in
                self?.action.onNext(.viewWillAppear)
            }
        case .moveToDetailScene(let controller, let title):
            guard let title = title else { break }
            switch title {
            case "회원탈퇴":
                let nickName = profileSection.inputDataList.first?.nickName
                let nextController = WithdrawlCheckModalController(nickName: nickName)
                nextController.reactor = WithdrawlCheckModalReactor()
                controller.presentPanModal(nextController)
                nextController.reactor?.state
                    .withUnretained(nextController)
                    .subscribe(onNext: { [weak controller] (nextController, state) in
                        switch state.state {
                        case .apply:
                            nextController.dismiss(animated: true) {
                                let reasonController = WithdrawlReasonController()
                                reasonController.reactor = WithdrawlReasonReactor()
                                controller?.navigationController?.pushViewController(reasonController, animated: true)
                            }
                        case .cancel:
                            nextController.dismiss(animated: true)
                        default:
                            break
                        }
                    })
                    .disposed(by: nextController.disposeBag)
            default:
                break
            }
        case.moveToLoginScene(let controller):
            let nextController = SubLoginController()
            nextController.reactor = SubLoginReactor()
            let navigationController = UINavigationController(rootViewController: nextController)
            navigationController.modalPresentationStyle = .fullScreen
            controller.present(navigationController, animated: true)
        case .moveToMyCommentScene(let controller):
            let nextController = MyCommentController()
            nextController.reactor = MyCommentReactor()
            controller.navigationController?.pushViewController(nextController, animated: true)
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
                spacing24Section,
                spacing16GraySection,
                spacing24Section
            ]
        }
    }
    
    func getNormalSection() -> [any Sectionable] {
        if isLogin {
            return [
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
                    spacing28Section,
                    logoutSection,
                    spacing100Section
                ]
            } else {
                return [
                    spacing16GraySection,
                    spacing28Section,
                    etcSection,
                    spacing28Section,
                    logoutSection,
                    spacing100Section
                ]
            }
        } else {
            return [spacing100Section]
        }
    }
}
