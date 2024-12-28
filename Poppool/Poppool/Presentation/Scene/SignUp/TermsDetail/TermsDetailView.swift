//
//  TermsDetailView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit

final class TermsDetailView: UIView {
    
    // MARK: - Components
    let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 15)
        return label
    }()
    
    let contentTextView: UITextView = {
        let view = UITextView()
        view.font = .KorFont(style: .regular, size: 15)
        view.isSelectable = false
        view.isEditable = false
        return view
    }()
    
    let xmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
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
private extension TermsDetailView {
    
    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(25)
            make.height.equalTo(21)
        }
        
        self.addSubview(xmarkButton)
        xmarkButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel)
        }
        
        self.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(43)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }
}
