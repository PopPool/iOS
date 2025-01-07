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
            make.leading.equalTo(cancelButton.snp.trailing)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
