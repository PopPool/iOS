//
//  SearchSortedView.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/6/24.
//

import UIKit

import SnapKit

final class SearchSortedView: UIView {
    
    // MARK: - Components
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18, text: "노출 순서을 선택해주세요")
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        return button
    }()
    
    private let filterTitleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13, text: "노출 조건")
        return label
    }()
    
    let filterSegmentControl: PPSegmentedControl = {
        let control = PPSegmentedControl(type: .base, segments: ["오픈", "종료"], selectedSegmentIndex: 0)
        return control
    }()
    
    private let sortedTitleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13, text: "팝업순서")
        return label
    }()
    
    let sortedSegmentControl: PPSegmentedControl = {
        let control = PPSegmentedControl(type: .base, segments: ["신규순", "인기순"], selectedSegmentIndex: 0)
        return control
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
private extension SearchSortedView {
    
    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(32)
        }
        
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
        }
        
        self.addSubview(filterTitleLabel)
        filterTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().inset(20)
        }
        
        self.addSubview(filterSegmentControl)
        filterSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(filterTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.addSubview(sortedTitleLabel)
        sortedTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(filterSegmentControl.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
        }
        
        self.addSubview(sortedSegmentControl)
        sortedSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(sortedTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(sortedSegmentControl.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}
