//
//  InfoEditModalView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/10/25.
//

import UIKit

import SnapKit

final class InfoEditModalView: UIView {
    
    // MARK: - Components
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18, text: "사용자 정보를 설정해주세요.")
        return label
    }()
    
    let xmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        return button
    }()
    
    private let genderTitleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13, text: "성별")
        return label
    }()
    
    let genderSegmentControl: PPSegmentedControl = {
        let control = PPSegmentedControl(type: .base, segments: ["남성", "여성", "선택안함"])
        return control
    }()
    
    private let ageTitleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13, text: "나이")
        return label
    }()
    
    let ageButton: AgeSelectedButton = {
        let label = AgeSelectedButton()
        return label
    }()
    
    let saveButton: PPButton = {
        let button = PPButton(style: .primary, text: "저장", disabledText: "저장")
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
private extension InfoEditModalView {
    
    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(32)
        }
        
        self.addSubview(xmarkButton)
        xmarkButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
        }
        
        self.addSubview(genderTitleLabel)
        genderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().inset(20)
        }
        
        self.addSubview(genderSegmentControl)
        genderSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(genderTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.addSubview(ageTitleLabel)
        ageTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(genderSegmentControl.snp.bottom).offset(36)
            make.leading.equalToSuperview().inset(20)
        }
        
        self.addSubview(ageButton)
        ageButton.snp.makeConstraints { make in
            make.top.equalTo(ageTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(72)
        }
        
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
