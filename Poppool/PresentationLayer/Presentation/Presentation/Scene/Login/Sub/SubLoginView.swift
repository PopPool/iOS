//
//  SubLoginView.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/28/24.
//

import UIKit

import SnapKit

final class SubLoginView: UIView {

    // MARK: - Components
    let xmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        button.tintColor = .g1000
        return button
    }()

    private let logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "image_login_logo")
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 16, text: "간편하게 SNS 로그인하고\n공감가는 코멘트에 반응해볼까요?\n다른 코멘트를 확인해볼까요?")
        label.setLineHeightText(text: "간편하게 SNS 로그인하고\n공감가는 코멘트에 반응해볼까요?\n다른 코멘트를 확인해볼까요?", font: .korFont(style: .bold, size: 16), lineHeight: 1.3)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    let kakaoButton: PPButton = {
        return PPButton(style: .kakao, text: "카카오톡으로 로그인")
    }()

    private let kakaoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_login_kakao")
        return view
    }()

    let appleButton: PPButton = {
        return PPButton(style: .apple, text: "Apple로 로그인")
    }()

    private let appleImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_login_apple")
        return view
    }()

    let inquiryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인이 어려우신가요?", for: .normal)
        button.titleLabel?.font = .korFont(style: .regular, size: 12)
        button.setTitleColor(.g1000, for: .normal)
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
private extension SubLoginView {

    func setUpConstraints() {
        self.addSubview(xmarkButton)
        xmarkButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(11)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(32)
        }

        self.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.height.equalTo(90)
            make.width.equalTo(70)
            make.top.equalTo(xmarkButton.snp.bottom).offset(75)
            make.centerX.equalToSuperview()
        }

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(28)
        }

        self.addSubview(kakaoButton)
        kakaoButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(156)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        kakaoButton.addSubview(kakaoImageView)
        kakaoImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(22)
        }

        self.addSubview(appleButton)
        appleButton.snp.makeConstraints { make in
            make.top.equalTo(kakaoButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        appleButton.addSubview(appleImageView)
        appleImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(22)
        }

        self.addSubview(inquiryButton)
        inquiryButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(56)
            make.centerX.equalToSuperview()
        }
    }
}
