import UIKit

import DesignSystem
import Infrastructure
import PresentationInterface
import SnapKit
import ReactorKit
import RxCocoa
import RxSwift

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
        if let lastLogin = reactor?.userDefaultService.fetch(key: "lastLogin") {
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
        reactor.pulse(\.$presentSignUp)
            .withUnretained(self)
            .subscribe { (owner, authrizationCode) in
                @Dependency var factory: SignUpFactory
                owner.navigationController?.pushViewController(
                    factory.make(
                        isFirstResponder: true,
                        authrizationCode: authrizationCode
                    ),
                    animated: true
                )
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$presentHome)
            .withUnretained(self)
            .subscribe { (owner, _) in
                @Dependency var factory: WaveTabbarFactory
                owner.view.window?.rootViewController = factory.make()
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$presentInquiry)
            .withUnretained(self)
            .subscribe { (owner, _) in
                @Dependency var factory: FAQFactory
                owner.navigationController?.pushViewController(
                    factory.make(),
                    animated: true
                )
            }
            .disposed(by: disposeBag)
    }
}
