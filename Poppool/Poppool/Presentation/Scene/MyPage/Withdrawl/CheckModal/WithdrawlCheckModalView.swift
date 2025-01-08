//
//  WithdrawlCheckModalView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/6/25.
//

import UIKit

import SnapKit

final class WithdrawlCheckModalView: UIView {
    
    // MARK: - Components
    let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18)
        return label
    }()
    
    private let trailingView: UIView = {
        let view = UIView()
        view.backgroundColor = .g50
        view.layer.cornerRadius = 4
        return view
    }()
    
    let cancelButton: PPButton = {
        let button = PPButton(style: .secondary, text: "취소")
        return button
    }()
    
    let agreeButton: PPButton = {
        let button = PPButton(style: .primary, text: "동의 후 탈퇴하기")
        return button
    }()
    
    let firstLabel: UILabel = {
        let text = "서비스 탈퇴 시 회원 전용 서비스 이용이 불가하며 회원 데이터는 일괄 삭제 처리돼요."
        let label = UILabel()
        label.setLineHeightText(text: text, font: .KorFont(style: .regular, size: 13), lineHeight: 1.4)
        label.numberOfLines = 2
        label.textColor = .g600
        return label
    }()
    
    let secondLabel: UILabel = {
        let text = "탈퇴 후에는 계정을 다시 살리거나 복구할 수 없어요."
        let label = UILabel()
        label.setLineHeightText(text: text, font: .KorFont(style: .regular, size: 13), lineHeight: 1.4)
        label.numberOfLines = 2
        label.textColor = .g600
        return label
    }()
    
    let thirdLabel: UILabel = {
        let text = "탈퇴 후 재가입은 14일이 지나야 가능해요."
        let label = UILabel()
        label.setLineHeightText(text: text, font: .KorFont(style: .regular, size: 13), lineHeight: 1.4)
        label.numberOfLines = 2
        label.textColor = .g600
        return label
    }()
    
    let fourthLabel: PPLabel = {
        let text = "작성하신 코멘트나 댓글 등의 일부 정보는 계속 남아있을 수 있어요. "
        let label = PPLabel(style: .regular, fontSize: 13, text: text)
        label.numberOfLines = 2
        label.textColor = .g600
        return label
    }()
    
    let textStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        return view
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
private extension WithdrawlCheckModalView {
    
    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(32)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.addSubview(trailingView)
        trailingView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(203)
        }
        
        self.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(108)
        }
        
        self.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalTo(cancelButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        trailingView.addSubview(textStackView)
        textStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        textStackView.addArrangedSubview(firstLabel)
        textStackView.addArrangedSubview(secondLabel)
        textStackView.addArrangedSubview(thirdLabel)
        textStackView.addArrangedSubview(fourthLabel)
    }
}
