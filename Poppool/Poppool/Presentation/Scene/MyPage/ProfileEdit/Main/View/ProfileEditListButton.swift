//
//  ProfileEditListButton.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/9/25.
//

import UIKit

import SnapKit

final class ProfileEditListButton: UIButton {
    
    // MARK: - Components
    let mainTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .g400
        return label
    }()
    
    let iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_right_gray")
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
private extension ProfileEditListButton {
    
    func setUpConstraints() {
        self.addSubview(mainTitleLabel)
        mainTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        self.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        self.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(iconImageView.snp.leading).offset(-4)
        }
    }
}
