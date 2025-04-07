//
//  MyCommentSortedModalView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import UIKit

import SnapKit

final class MyCommentSortedModalView: UIView {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 18, text: "보기 옵션을 선택해주세요")
    }()

    let xmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        return button
    }()

    let sortedSegmentControl: PPSegmentedControl = {
        return PPSegmentedControl(type: .base, segments: ["최신순", "반응순"])
    }()

    let saveButton: PPButton = {
        return PPButton(style: .primary, text: "저장", disabledText: "저장")
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
private extension MyCommentSortedModalView {

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

        self.addSubview(sortedSegmentControl)
        sortedSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }

        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

    }
}
