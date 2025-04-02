//
//  PPReturnHeaderView.swift
//  Poppool
//
//  Created by Porori on 11/27/24.
//

import SnapKit
import UIKit

final class PPReturnHeaderView: UIView {

    // MARK: - Components
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_backButton"), for: .normal)
        button.tintColor = .black
        return button
    }()

    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .KorFont(style: .regular, size: 15)
        label.textColor = .g1000
        return label
    }()

    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        headerLabel.text = text
    }
}

// MARK: - SetUp
private extension PPReturnHeaderView {

    func setUpConstraints() {
        self.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(12)
            make.size.equalTo(28)
        }

        self.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
    }
}
