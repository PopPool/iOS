import UIKit

import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift

final class FAQReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case dropButtonTapped(row: Int)
        case backButtonTapped(controller: BaseViewController)
        case mailInquiryCellTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case moveToRecentScene(controller: BaseViewController)
        case moveToMailApp(controller: BaseViewController)
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
        .init(
            title: "비회원도 사용할 수 있나요?",
            content: "비회원이시라도 팝풀에서 제공하는 서비스를 이용할 수 있어요. 단, 팝업스토어 찜하기, 코멘트 남기기 등 일부 기능은 사용할 수 없어요.",
            isOpen: false
        ),
        .init(
            title: "회원 정보를 수정하고 싶어요.",
            content: "[마이페이지 > 설정 > 프로필 수정]에서 회원정보를 수정하실 수 있어요. 단, 가입 시 연동한 이메일 계정은 수정이 불가능해요.",
            isOpen: false
        ),
        .init(
            title: "회원을 탈퇴하고 싶어요.",
            content: "[마이페이지] 하단의 '회원 탈퇴' 버튼을 클릭해 탈퇴할 수 있어요.",
            isOpen: false
        ),
        .init(
            title: "추천 팝업은 어떤 기준으로 보여지나요?",
            content: "추천 팝업은 고객님께서 선택하신 맞춤 정보(성별, 연령대, 관심사)와 연관된 팝업스토어 정보를 기준으로 추천해드려요.",
            isOpen: false
        ),
        .init(
            title: "팝업스토어 정보가 없거나 정보가 달라요.",
            content: "[마이페이지 > 고객문의 > 메일로 문의]로 내용을 알려주시면 빠른 시일 내 추가/수정할게요.",
            isOpen: false
        ),
        .init(
            title: "고객센터 상담은 어디서 할 수 있나요?",
            content: "[마이페이지 > 고객문의 > 메일로 문의]에서 할 수 있으며, 주말, 공휴일을 제외한 평일 오전 9시부터 오후 6시까지 운영해요.",
            isOpen: false
        )

    ])
    private let qnaTitleSection = MyPageMyCommentTitleSection(inputDataList: [.init(title: "직접 문의하기")])
    private var qnaSection = MyPageListSection(inputDataList: [
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
        case .mailInquiryCellTapped(let controller):
            return Observable.just(.moveToMailApp(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .moveToMailApp(let controller):
            let email = "service.poppool@gmail.com"
            let mailtoURLString = "mailto:\(email)"
            if let emailURL = URL(string: mailtoURLString), UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
            } else {
                showMailAppRecoveryAlert(controller: controller)
            }
        }
        return newState
    }

    func showMailAppRecoveryAlert(controller: BaseViewController) {

        let alert = UIAlertController(
            title: "'Mail' 앱을 복원하겠습니까?",
            message: "계속하려면 App Store에서 'Mail' 앱을\n다운로드하십시오",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "App Store로 이동", style: .default, handler: { _ in
            // 📌 App Store의 메일 앱 복구 페이지 열기
            if let mailAppURL = URL(string: "itms-apps://itunes.apple.com/app/id1108187098") {
                UIApplication.shared.open(mailAppURL, options: [:], completionHandler: nil)
            }
        }))

        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        controller.present(alert, animated: true, completion: nil)
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
