//
//  ValidationTextField.swift
//  PopPool
//
//  Created by SeoJunYoung on 7/8/24.
//

import UIKit
import RxSwift
import RxCocoa

final class ValidationTextField: BaseTextFieldCPNT {
    
    enum ValidationType {
        case nickName
    }
    
    enum ValidationState {
        case none
        case requestKorOrEn
        case requestButtonTap
        case overText
        case shortText
        case duplicateNickname
        case valid
    }
    
    struct ValidationOutPut {
        var type: ValidationType
        var state: ValidationState
        
        var description: String? {
            switch state {
            case .none:
                return nil
            case .requestKorOrEn:
                return "한글, 영문으로만 입력해주세요"
            case .requestButtonTap:
                return "중복체크를 진행해주세요"
            case .overText:
                return "10글자까지만 입력할 수 있어요"
            case .shortText:
                return "2글자 이상 입력해주세요"
            case .duplicateNickname:
                return "이미 사용되고 있는 별명이에요"
            case .valid:
                return "사용 가능한 별명이에요"
            }
        }
        
        var borderColor: UIColor {
            switch state {
            case .overText, .duplicateNickname, .shortText, .requestKorOrEn:
                return UIColor.re500
            case .none, .requestButtonTap:
                return UIColor.g100
            case .valid:
                return UIColor.g1000
            }
        }
        
        var countLabelColor: UIColor {
            switch state {
            case .overText, .shortText:
                return UIColor.re500
            default:
                return UIColor.g500
            }
        }
        
        var descriptionColor: UIColor {
            switch state {
            case .overText, .duplicateNickname, .shortText, .requestKorOrEn:
                return UIColor.re500
            case .none, .requestButtonTap:
                return UIColor.g100
            case .valid:
                return UIColor.blu500
            }
        }
        
        var isClearButtonHidden: Bool {
            switch state {
            case .none, .requestKorOrEn, .requestButtonTap, .valid:
                // 안 보이는 시점
                return true
                
            case .shortText, .duplicateNickname, .overText:
                // 보이는 시점
                return false
            }
        }
        
        var isDuplicateCheckButtonHidden: Bool {
            switch state {
            case .none, .shortText, .overText, .duplicateNickname:
                return true
               
            case .requestButtonTap:
                return false
                
            default:
                return false
            }
        }
    }
    
    // MARK: - Components
    
    private let checkValidationStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    private let checkValidationButton: UIButton = {
        let button = UIButton()
        button.setTitle("중복체크", for: .normal)
        button.titleLabel?.font = .KorFont(style: .regular, size: 13)
        button.setTitleColor(.g1000, for: .normal)
        return button
    }()
    
    private let checkValidationLine: UIView = {
        let line = UIView()
        line.layer.borderColor = UIColor.g300.cgColor
        line.layer.borderWidth = 1
        return line
    }()
    
    // MARK: - Properties
    
    private let stateObserver:PublishSubject<ValidationState> = .init()
    private let type: ValidationType
    
    // MARK: - Initializer
    
    init(placeHolder: String?, type: ValidationType = .nickName, limitTextCount: Int) {
        self.type = type
        super.init(placeHolder: placeHolder, description: "", limitTextCount: limitTextCount)
        setUpDuplicatecheck()
        bind()
    }
    
    // MARK: - Methods
    
    private func setUpDuplicatecheck() {
        checkValidationStack.addArrangedSubview(checkValidationButton)
        checkValidationStack.addArrangedSubview(checkValidationLine)
        checkValidationLine.snp.makeConstraints { make in
            make.height.equalTo(1
            )
        }
        textFieldStackView.addArrangedSubview(checkValidationStack)
    }
    
    private func bind() {
        stateObserver
            .withUnretained(self)
            .subscribe { (owner, state) in
                let output = ValidationOutPut(type: owner.type, state: state)
                owner.setUpViewFrom(output: output)
            }
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .withUnretained(self)
            .subscribe { (owner, text) in
                let state = owner.fetchValidationState(text: text)
                owner.stateObserver.onNext(state)
            }
            .disposed(by: disposeBag)
        
        clearButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, value) in
                owner.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        checkValidationButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, value) in
                print("중복 체크 버튼이 눌렸습니다.")
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchValidationState(text: String) -> ValidationState {
        if text.count == 0 {
            return .none
        } else if text.count < 2 {
            return .shortText
        } else if text.count > 10 {
            return .overText
        }
        
        let regex = "^[가-힣A-Za-z0-9\\s]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        if !predicate.evaluate(with: text) {
            return .requestKorOrEn
        }
        return .valid
    }
    
    private func setUpViewFrom(output: ValidationOutPut) {
        
        // 색상 적용
        self.descriptionLabel.text = output.description
        self.descriptionLabel.textColor = output.descriptionColor
        self.textFieldBackGroundView.layer.borderColor = output.borderColor.cgColor
        self.textCountLabel.textColor = output.countLabelColor
        
        // 텍스트 필드 반전
        self.clearButton.isHidden = output.isClearButtonHidden
        self.checkValidationStack.isHidden = output.isDuplicateCheckButtonHidden
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
