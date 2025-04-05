//
//  SignUpCompleteView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/27/24.
//

import UIKit

import SnapKit

final class SignUpCompleteView: UIView {

    // MARK: - Components
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "image_signUp_complete")
        return view
    }()

    private let titleTopLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 20, text: "가입완료")
    }()

    private let titleMiddleStackView: UIStackView = {
        return UIStackView()
    }()

    let nickNameLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 20)
        label.textColor = .blu500
        return label
    }()

    private let nickNameSubLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 20, text: "님의")
    }()

    private let titleBottomLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 20, text: "피드를 확인해보세요")
    }()

    private let titleStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        return view
    }()

    let descriptionLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 15)
        label.textColor = .g600
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    let bottomButton: PPButton = {
        return PPButton(style: .primary, text: "바로가기")
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
private extension SignUpCompleteView {

    func setUpConstraints() {
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
            make.top.equalToSuperview().inset(124)
        }

        titleMiddleStackView.addArrangedSubview(nickNameLabel)
        titleMiddleStackView.addArrangedSubview(nickNameSubLabel)

        titleStackView.addArrangedSubview(titleTopLabel)
        titleStackView.addArrangedSubview(titleMiddleStackView)
        titleStackView.addArrangedSubview(titleBottomLabel)

        self.addSubview(titleStackView)
        titleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(32)
        }

        self.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)

        }

        self.addSubview(bottomButton)
        bottomButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
    }
}
