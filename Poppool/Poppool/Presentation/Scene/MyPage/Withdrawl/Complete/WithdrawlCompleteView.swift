//
//  WithdrawlCompleteView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/7/25.
//

import UIKit

import SnapKit

final class WithdrawlCompleteView: UIView {

    // MARK: - Components
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_check_fill_blue")
        return view
    }()

    private let titleLabel: PPLabel = {
        let text = "탈퇴 완료\n다음에 또 만나요"
        let label = PPLabel(style: .bold, fontSize: 20, text: text)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: PPLabel = {
        let text = "고객님이 만족하실 수 있는\n팝풀이 되도록 앞으로도 노력할게요 :)"
        let label = PPLabel(style: .regular, fontSize: 15, text: text)
        label.setLineHeightText(text: text, font: .KorFont(style: .regular, size: 15), lineHeight: 1.5)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .g600
        return label
    }()

    let checkButton: PPButton = {
        return PPButton(style: .primary, text: "확인")
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
private extension WithdrawlCompleteView {

    func setUpConstraints() {
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(80)
            make.top.equalToSuperview().inset(84)
            make.centerX.equalToSuperview()
        }

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(64)
            make.centerX.equalToSuperview()
        }

        self.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        self.addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
