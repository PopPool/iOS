import UIKit

import DesignSystem
import Infrastructure
import PresentationInterface
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class LoginViewController: BaseViewController, View {

    typealias Reactor = LoginReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = LoginView()

    override func loadView() {
        self.view = mainView
    }
}

// MARK: - Life Cycle
extension LoginViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let lastLogin = reactor?.userDefaultService.fetch(keyType: .lastLogin) {
            switch lastLogin {
            case "kakao":
                mainView.kakaoButton.showToolTip(color: .w100, direction: .pointDown)
            case "apple":
                mainView.appleButton.showToolTip(color: .w100, direction: .pointUp)
            default:
                break
            }
        }
    }
}

extension LoginViewController {
    func bind(reactor: Reactor) {
        bindInput(reactor: reactor)
        bindOutput(reactor: reactor)
    }

    private func bindInput(reactor: Reactor) {
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
        reactor.state.distinctUntilChanged(\.isSubLogin)
            .compactMap { $0.isSubLogin }
            .withUnretained(self)
            .subscribe { (owner, isSubLogin) in
                switch isSubLogin {
                case true:
                    owner.mainView.guestButton.isHidden = true
                    owner.mainView.xmarkButton.isHidden = false
                    owner.mainView.setTitle("간편하게 SNS 로그인하고\n공감가는 코멘트에 반응해볼까요?\n다른 코멘트를 확인해볼까요?")

                case false:
                    owner.mainView.guestButton.isHidden = false
                    owner.mainView.xmarkButton.isHidden = true
                    owner.mainView.setTitle("간편하게 SNS 로그인하고\n팝풀 서비스를 이용해보세요")
                }
            }
            .disposed(by: disposeBag)

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
    }
}
