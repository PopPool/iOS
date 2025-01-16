//
//  LoginController.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/24/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class LoginController: BaseViewController, View {
    
    typealias Reactor = LoginReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = LoginView()
}

// MARK: - Life Cycle
extension LoginController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let lastLogin = reactor?.userDefaultService.fetch(key: "lastLogin") {
            switch lastLogin {
            case "kakao":
                mainView.kakaoButton.showToolTip(color: .w100, direction: .pointDown, text: "최근에 이 방법으로 로그인했어요")
            case "apple":
                mainView.appleButton.showToolTip(color: .w100, direction: .pointUp, text: "최근에 이 방법으로 로그인했어요")
            default:
                break
            }
        }
    }
}

// MARK: - SetUp
private extension LoginController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension LoginController {
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
        
        mainView.appleButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.appleButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
