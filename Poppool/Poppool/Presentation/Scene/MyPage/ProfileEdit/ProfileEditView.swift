//
//  ProfileEditView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/4/25.
//

import UIKit

import SnapKit

final class ProfileEditView: UIView {
    
    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "프로필 설정", font: .KorFont(style: .regular, size: 15))
        return view
    }()
    
    let saveButton: PPButton = {
        let button = PPButton(style: .primary, text: "저장", disabledText: "저장")
        return button
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let contentView: UIView = UIView()
    
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
private extension ProfileEditView {
    
    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        
        
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(saveButton.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}
