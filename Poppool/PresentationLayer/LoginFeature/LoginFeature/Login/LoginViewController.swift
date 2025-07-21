import UIKit

import DesignSystem
import Infrastructure
import LoginFeatureInterface
import PresentationInterface
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

/// 다른 처리가 뭐가 있을까
/// 1. 코멘트 타이틀
///     1-1. 외부로부터 주입(상황에 맞춰 적절한 코멘트를 띄우기 위함)
/// 2. 우상단 버튼의 형태
///     2-1. 둘러보기/xmark
///     2-2. 버튼의 타입만 전달받도록?
///     2-3. 사이즈가 달라서 어려움이 있다고 봄
/// 3. 우상단 버튼의 동작 -> 클로저로 넘긴다면 Reactor로 어떻게 처리?
///     3-1. 일단 받아두고 reactor로부터 명령이 오면 실행
///     3-2. 이러면 viewController를 만들 때 클로저를 넣어줘야됨. -> factory, init 변경
/// 4. 배경 색상
///     4-1. g50 -> subLogin
///     4-2. w100 -> main login

final class LoginViewController: BaseViewController, View {

    typealias Reactor = LoginReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = LoginView()

    public convenience init(
        loginSceneType: LoginSceneType,
        text: String
    ) {
        self.init()

        self.mainView.setCloseButton(for: loginSceneType)
        self.mainView.setTitle(text)
    }

    private override init() {
        super.init()
    }

    public required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }

    override func loadView() {
        self.view = mainView
    }
}

extension LoginViewController {
    func bind(reactor: Reactor) {
        bindInput(reactor: reactor)
        bindOutput(reactor: reactor)
    }

    private func bindInput(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.guestButton.rx.tap
            .map { Reactor.Action.guestButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.xmarkButton.rx.tap
            .map { Reactor.Action.xmarkButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.kakaoButton.rx.tap
            .map { Reactor.Action.kakaoButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.inquiryButton.rx.tap
            .map { Reactor.Action.inquiryButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.appleButton.rx.tap
            .map { Reactor.Action.appleButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindOutput(reactor: Reactor) {
        reactor.pulse(\.$present)
            .skip(1)
            .withUnretained(self)
            .subscribe { (owner, target) in
                switch target! {
                case .signUp(let isFirstResponder, let authrizationCode):
                    @Dependency var factory: SignUpFactory
                    owner.navigationController?.pushViewController(
                        factory.make(
                            isFirstResponder: isFirstResponder,
                            authrizationCode: authrizationCode
                        ),
                        animated: true
                    )

                case .home:
                    @Dependency var factory: WaveTabbarFactory
                    owner.view.window?.rootViewController = factory.make()

                case .dismiss:
                    owner.dismiss(animated: true)

                case .inquiry:
                    @Dependency var factory: FAQFactory
                    owner.navigationController?.pushViewController(
                        factory.make(),
                        animated: true
                    )
                }
            }
            .disposed(by: disposeBag)

        reactor.state.distinctUntilChanged(\.tooltipType)
            .skip(1)
            .map { $0.tooltipType }
            .withUnretained(self)
            .subscribe { (owner, type) in
                switch type {
                case .kakao:
                    owner.mainView.kakaoButton.showToolTip(color: .w100, direction: .pointDown)
                case .apple:
                    owner.mainView.appleButton.showToolTip(color: .w100, direction: .pointUp)
                case .none:
                    return
                }
            }
            .disposed(by: disposeBag)
    }
}
