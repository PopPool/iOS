//
//  MyPageReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/30/24.
//

import ReactorKit
import RxCocoa
import RxSwift
import UIKit

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
        case adminMenuTapped(controller: BaseViewController)  // ← 관리자 메뉴 액션 추가
    }

    enum Mutation {
        case loadView
        case moveToProfileEditScene(controller: BaseViewController)
        case logout
        case moveToDetailScene(controller: BaseViewController, title: String?)
        case moveToPopUpDetailScene(controller: BaseViewController, row: Int)
        case moveToLoginScene(controller: BaseViewController)
        case moveToMyCommentScene(controller: BaseViewController)
        case moveToAdminScene(controller: BaseViewController) // ← 관리자 메뉴 이동 추가
    }

    struct State {
        var sections: [any Sectionable] = []
        var isLogin: Bool = false
        var backgroundImageViewPath: String?
    }

    // MARK: - properties
    var initialState: State
    var disposeBag = DisposeBag()

    private let userAPIUseCase: UserAPIUseCase

    lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self = self else {
                return NSCollectionLayoutSection(
                    group: NSCollectionLayoutGroup(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                )
            }
            return getSection()[section].getSection(section: section, env: env)
        }
    }()

    // 섹션들
    private var profileSection = MyPageProfileSection(inputDataList: [])
    private var commentTitleSection = MyPageMyCommentTitleSection(inputDataList: [.init(title: "내가 코멘트한 팝업", buttonTitle: "전체보기")])
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

    /// 관리자 모드용 etcSection
    private var adminEtcSection = MyPageListSection(inputDataList: [
        .init(title: "회원탈퇴"),
        .init(title: "관리자 메뉴 바로가기")
    ])

    private var logoutSection = MyPageLogoutSection(inputDataList: [.init()])

    private let spacing8Section = SpacingSection(inputDataList: [.init(spacing: 8)])
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private let spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private let spacing28Section = SpacingSection(inputDataList: [.init(spacing: 28)])
    private let spacing16GraySection = SpacingSection(inputDataList: [.init(spacing: 16, backgroundColor: .g50)])
    private let spacing156Section = SpacingSection(inputDataList: [.init(spacing: 156)])

    var isLogin: Bool = false
    var isAdmin: Bool = false

    // MARK: - init
    init(userAPIUseCase: UserAPIUseCase) {
        self.userAPIUseCase = userAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {

        case .viewWillAppear:
            // 로그인 여부 & 관리자 여부 등 MyPage 정보 가져오기
            return userAPIUseCase.getMyPage()
                .withUnretained(self)
                .map { (owner, response) in
                    owner.isLogin = response.loginYn
                    owner.isAdmin = response.adminYn

                    // 프로필
                    owner.profileSection.inputDataList = [
                        .init(
                            isLogin: response.loginYn,
                            profileImagePath: response.profileImageUrl,
                            nickName: response.nickname,
                            description: response.intro
                        )
                    ]
                    // 내가 댓글 단 팝업 리스트
                    owner.commentSection.inputDataList = response.myCommentedPopUpList.map {
                        .init(popUpImagePath: $0.mainImageUrl, title: $0.popUpStoreName, popUpID: $0.popUpStoreId)
                    }
                    if !owner.commentSection.inputDataList.isEmpty {
                        owner.commentSection.inputDataList[0].isFirstCell = true
                    }
                    return .loadView
                }

        case .settingButtonTapped(let controller):
            return .just(.moveToProfileEditScene(controller: controller))

        case .commentButtonTapped(let controller):
            return .just(.moveToMyCommentScene(controller: controller))

        case .commentCellTapped(let controller, let row):
            return .just(.moveToPopUpDetailScene(controller: controller, row: row))

        case .loginButtonTapped(let controller):
            return .just(.moveToLoginScene(controller: controller))

        case .listCellTapped(let controller, let title):
            // 일반 리스트 셀 탭
            // 만약 "관리자 메뉴 바로가기"라면 adminScene으로 이동
            if title == "관리자 메뉴 바로가기" {
                return .just(.moveToAdminScene(controller: controller))
            } else {
                return .just(.moveToDetailScene(controller: controller, title: title))
            }

        case .logoutButtonTapped:
            // 로그아웃 API
            return userAPIUseCase.postLogout()
                .andThen(Observable.just(.logout))

        case .adminMenuTapped(let controller):
            // 별도의 액션으로도 관리자 메뉴로 이동 가능
            return .just(.moveToAdminScene(controller: controller))
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
            nextController.reactor = ProfileEditReactor(
                userAPIUseCase: userAPIUseCase,
                signUpAPIUseCase: DIContainer.resolve(SignUpAPIUseCase.self)
            )
            controller.navigationController?.pushViewController(nextController, animated: true)

        case .logout:
            @Dependency var keyChainService: KeyChainService
            _ = keyChainService.deleteToken(type: .accessToken)
            _ = keyChainService.deleteToken(type: .refreshToken)
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
                                reasonController.reactor = WithdrawlReasonReactor(userAPIUseCase: self.userAPIUseCase)
                                controller?.navigationController?.pushViewController(reasonController, animated: true)
                            }
                        case .cancel:
                            nextController.dismiss(animated: true)
                        default:
                            break
                        }
                    })
                    .disposed(by: nextController.disposeBag)

            case "차단한 사용자 관리":
                let nextController = BlockUserManageController()
                nextController.reactor = BlockUserManageReactor(userAPIUseCase: userAPIUseCase)
                controller.navigationController?.pushViewController(nextController, animated: true)

            case "공지사항":
                let nextController = MyPageNoticeController()
                nextController.reactor = MyPageNoticeReactor(userAPIUseCase: userAPIUseCase)
                controller.navigationController?.pushViewController(nextController, animated: true)

            case "고객문의":
                let nextController = FAQController()
                nextController.reactor = FAQReactor()
                controller.navigationController?.pushViewController(nextController, animated: true)

            case "찜한 팝업":
                let nextController = MyPageBookmarkController()
                nextController.reactor = MyPageBookmarkReactor(userAPIUseCase: userAPIUseCase)
                controller.navigationController?.pushViewController(nextController, animated: true)

            case "최근 본 팝업":
                let nextController = MyPageRecentController()
                nextController.reactor = MyPageRecentReactor(userAPIUseCase: userAPIUseCase)
                controller.navigationController?.pushViewController(nextController, animated: true)

            case "약관":
                let nextController = MyPageTermsController()
                nextController.reactor = MyPageTermsReactor()
                controller.navigationController?.pushViewController(nextController, animated: true)
            default:
                break
            }

        case .moveToPopUpDetailScene(let controller, let row):
            let nextController = DetailController()
            let popUpID = commentSection.inputDataList[row].popUpID
            nextController.reactor = DetailReactor(
                popUpID: popUpID,
                userAPIUseCase: userAPIUseCase,
                popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
                commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self)
            )
            controller.navigationController?.pushViewController(nextController, animated: true)

        case .moveToLoginScene(let controller):
            let nextController = SubLoginController()
            nextController.reactor = SubLoginReactor(
                authAPIUseCase: DIContainer.resolve(AuthAPIUseCase.self)
            )
            let navigationController = UINavigationController(rootViewController: nextController)
            navigationController.modalPresentationStyle = .fullScreen
            controller.present(navigationController, animated: true)
        case .moveToMyCommentScene(let controller):
            let nextController = MyCommentController()
            nextController.reactor = MyCommentReactor(userAPIUseCase: userAPIUseCase)
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .moveToAdminScene(let controller):
            // 관리자 VC
            let nickname = profileSection.inputDataList.first?.nickName ?? ""
            let adminUseCase = AdminUseCaseImpl(
                repository: AdminRepositoryImpl(provider: ProviderImpl())
            )
            let adminVC = AdminViewController(nickname: nickname, adminUseCase: adminUseCase)
            adminVC.reactor = AdminReactor(useCase: adminUseCase)
            controller.navigationController?.pushViewController(adminVC, animated: true)
        }

        // 배경 프로필 이미지
        if !profileSection.isEmpty {
            newState.backgroundImageViewPath = profileSection.inputDataList.first?.profileImagePath
        }

        return newState
    }

    // MARK: - Composing Sections
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
                normalSection,
                spacing8Section
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
                spacing8Section
            ]
        } else {
            return [
                infoTitleSection,
                spacing16Section,
                infoSection,
                spacing8Section
            ]
        }
    }

    func getETCSection() -> [any Sectionable] {
        if isLogin {
            if isAdmin {
                // 관리자 모드
                return [
                    spacing16GraySection,
                    spacing28Section,
                    adminEtcSection,   // "회원탈퇴" + "관리자 메뉴 바로가기"
                    spacing28Section,
                    logoutSection,
                    spacing156Section
                ]
            } else {
                // 일반 모드
                return [
                    spacing16GraySection,
                    spacing28Section,
                    etcSection,        // "회원탈퇴"
                    spacing28Section,
                    logoutSection,
                    spacing156Section
                ]
            }
        } else {
            // 미로그인
            return [spacing156Section]
        }
    }
}
