//
//  SignUpStep4Controller.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class SignUpStep4Controller: BaseViewController, View {

    typealias Reactor = SignUpStep4Reactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    var mainView = SignUpStep4View()
}

// MARK: - Life Cycle
extension SignUpStep4Controller {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension SignUpStep4Controller {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SignUpStep4Controller {
    func bind(reactor: Reactor) {
        mainView.genderSegmentControl.rx.selectedSegmentIndex
            .map({ index in
                Reactor.Action.selectedGender(index: index)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.ageSelectedButton.button.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.ageSelectedButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.ageSelectedButton.injection(with: .init(age: state.age))
                if state.age == nil {
                    owner.mainView.completeButton.isEnabled = false
                } else {
                    owner.mainView.completeButton.isEnabled = true
                }
            }
            .disposed(by: disposeBag)
    }
}
