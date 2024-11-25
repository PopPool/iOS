//
//  SignUpStep2Controller.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import RxGesture

final class SignUpStep2Controller: BaseViewController, View {
    
    typealias Reactor = SignUpStep2Reactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    var mainView = SignUpStep2View()
}

// MARK: - Life Cycle
extension SignUpStep2Controller {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension SignUpStep2Controller {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SignUpStep2Controller {
    func bind(reactor: Reactor) {
        
        mainView.rx.tapGesture()
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        mainView.textField.rx.text
            .map { Reactor.Action.inputNickName(text: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.textField.rx.controlEvent(.editingDidBegin)
            .map { Reactor.Action.beginNickNameInput }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.textField.rx.controlEvent(.editingDidEnd)
            .map { Reactor.Action.endNickNameInput }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.clearButton.rx.tap
            .map { Reactor.Action.clearButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.duplicatedCheckButton.rx.tap
            .map { Reactor.Action.duplicatedButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                
                // duplicatedButton Active set
                switch state.nickNameState {
                case .check, .checkActive:
                    owner.mainView.duplicatedCheckButton.isEnabled = true
                default:
                    owner.mainView.duplicatedCheckButton.isEnabled = false
                }

                // border, text, textColor set
                owner.mainView.textFieldTrailingView.layer.borderColor = state.nickNameState.borderColor?.cgColor
                owner.mainView.textDescriptionLabel.text = state.nickNameState.description
                owner.mainView.textDescriptionLabel.textColor = state.nickNameState.textColor
                
                // clearButton, Duplicated Button set
                if state.isActiveInput {
                    owner.mainView.duplicatedCheckButton.isHidden = true
                    owner.mainView.clearButton.isHidden = false
                } else {
                    owner.mainView.duplicatedCheckButton.isHidden = false
                    owner.mainView.clearButton.isHidden = true
                }
                
                // count Label set
                if let nickName = state.nickName {
                    owner.mainView.textCountLabel.text = "\(nickName.count) / 10자"
                }
                switch state.nickNameState {
                case .duplicated, .duplicatedActive, .korAndEng, .korAndEngActive, .length, .lengthActive:
                    owner.mainView.textCountLabel.textColor = .re500
                default:
                    owner.mainView.textCountLabel.textColor = .g500
                }
                
                
                // completeButton isActive set
                switch state.nickNameState {
                case .validate, .validateActive:
                    owner.mainView.completeButton.isEnabled = true
                default:
                    owner.mainView.completeButton.isEnabled = false
                }
            }
            .disposed(by: disposeBag)
    }
}
