import UIKit

import DesignSystem

import SnapKit

final class CommentUserBlockView: UIView {

    // MARK: - Components
    let titleLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 18, text: "님을 차단할까요?")
    }()

    private let descriptionLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 14, text: "차단하시면 앞으로 이 유저가 남긴\n코멘트와 반응을 볼 수 없어요.")
        label.numberOfLines = 2
        label.textColor = .g600
        return label
    }()

    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 12
        return view
    }()

    let cancelButton: PPButton = {
        return PPButton(style: .secondary, text: "취소")
    }()

    let blockButton: PPButton = {
        return PPButton(style: .primary, text: "차단하기")
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
private extension CommentUserBlockView {

    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(32)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(blockButton)
        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
//            make.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}
