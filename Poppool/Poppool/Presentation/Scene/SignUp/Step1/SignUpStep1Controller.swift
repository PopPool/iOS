//
//  SignUpStep1Controller.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class SignUpStep1Controller: BaseViewController, View {

    typealias Reactor = SignUpStep1Reactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    var mainView = SignUpStep1View()
}

// MARK: - Life Cycle
extension SignUpStep1Controller {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension SignUpStep1Controller {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SignUpStep1Controller {
    func bind(reactor: Reactor) {

        // totalButton Tap 이벤트
        mainView.totalButton.button.rx.tap
            .map { Reactor.Action.totalButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // terms Tap 이벤트
        mainView.terms1Button.button.rx.tap
            .map { Reactor.Action.termsButtonTapped(index: 1)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        mainView.terms2Button.button.rx.tap
            .map { Reactor.Action.termsButtonTapped(index: 2)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        mainView.terms3Button.button.rx.tap
            .map { Reactor.Action.termsButtonTapped(index: 3)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        mainView.terms4Button.button.rx.tap
            .map { Reactor.Action.termsButtonTapped(index: 4)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // terms Detail Button 이벤트
        mainView.terms1Button.righticonButton.rx.tap
            .withUnretained(self)
            .map({ (owner, _) in
                Reactor.Action.termsRightButtonTapped(index: 1, controller: owner)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        mainView.terms2Button.righticonButton.rx.tap
            .withUnretained(self)
            .map({ (owner, _) in
                Reactor.Action.termsRightButtonTapped(index: 2, controller: owner)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        mainView.terms3Button.righticonButton.rx.tap
            .withUnretained(self)
            .map({ (owner, _) in
                Reactor.Action.termsRightButtonTapped(index: 3, controller: owner)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        mainView.terms4Button.righticonButton.rx.tap
            .withUnretained(self)
            .map({ (owner, _) in
                Reactor.Action.termsRightButtonTapped(index: 4, controller: owner)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in

                // selectedIndex가 4일 경우 전체 선택 버튼 활성화 및 비활성화
                if state.selectedIndex.count == 4 {
                    owner.mainView.totalButton.isSelected.accept(true)
                } else {
                    owner.mainView.totalButton.isSelected.accept(false)
                }

                // 현 selectedIndex에 따라 view 변경
                let termsViews = [
                    owner.mainView.terms1Button,
                    owner.mainView.terms2Button,
                    owner.mainView.terms3Button,
                    owner.mainView.terms4Button
                ]
                for (index, view) in termsViews.enumerated() {
                    let isSelected = state.selectedIndex.contains(index + 1)
                    view.isSelected.accept(isSelected)
                }

                // selectedIndex가 1,2,3을 포함할 시 completeButton 활성화
                if state.selectedIndex.contains(1)
                    && state.selectedIndex.contains(2)
                    && state.selectedIndex.contains(3) {
                    owner.mainView.completeButton.isEnabled = true
                } else {
                    owner.mainView.completeButton.isEnabled = false
                }
            }
            .disposed(by: disposeBag)
    }
}
