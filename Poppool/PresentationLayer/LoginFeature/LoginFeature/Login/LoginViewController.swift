import UIKit

import DesignSystem
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
        mainView.guestButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.guestButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.kakaoButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.kakaoButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.inquiryButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.inquiryButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.appleButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.appleButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
