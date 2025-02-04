//
//  SignUpStep1View.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit

final class SignUpStep1View: UIView {
    
    // MARK: - Components
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 20, text: "서비스 이용을 위한\n약관을 확인해주세요")
        label.numberOfLines = 0
        return label
    }()
    
    let totalButton: SignUpCheckBoxButton = {
        let button = SignUpCheckBoxButton()
        return button
    }()
    
    let terms1Button: SignUpTermsView = SignUpTermsView(title: "[필수] 이용약관")
    let terms2Button: SignUpTermsView = SignUpTermsView(title: "[필수] 개인정보 수집 및 이용")
    let terms3Button: SignUpTermsView = SignUpTermsView(title: "[필수] 만 14세 이상")
    
    let termsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        return view
    }()
    
    let completeButton: PPButton = {
        let button = PPButton(style: .primary, text: "확인", disabledText: "확인")
        return button
    }()
    
    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension SignUpStep1View {
    
    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(64)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        self.addSubview(totalButton)
        totalButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(49)
        }
        
        self.addSubview(termsStackView)
        termsStackView.snp.makeConstraints { make in
            make.top.equalTo(totalButton.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        termsStackView.addArrangedSubview(terms1Button)
        termsStackView.addArrangedSubview(terms2Button)
        termsStackView.addArrangedSubview(terms3Button)
        
        self.addSubview(completeButton)
        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        
        terms3Button.righticonButton.isHidden = true
    }
}
