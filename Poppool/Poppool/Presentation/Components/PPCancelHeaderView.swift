//
//  PPCancelHeaderView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit

final class PPCancelHeaderView: UIView {

    // MARK: - Components
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_backButton"), for: .normal)
        button.tintColor = .black
        return button
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .KorFont(style: .regular, size: 14)
        button.setTitleColor(.black, for: .normal)
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
private extension PPCancelHeaderView {

    func setUpConstraints() {
        self.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(12)
        }

        self.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().inset(20)
        }
    }
}
