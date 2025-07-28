import UIKit

import DesignSystem

import SnapKit
import Then

final class CommentCheckView: UIView {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        return PPLabel(text: "코멘트 작성을 그만하시겠어요?", style: .KOb18)
    }()

    private let descriptionLabel = PPLabel(
        text: "화면을 나가실 경우 작성중인 내용은 저장되지 않아요.",
        style: .KOr14
    ).then {
        $0.textColor = .g600
    }

    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 12
        return view
    }()

    let continueButton: PPButton = {
        return PPButton(style: .secondary, text: "계속하기")
    }()

    let stopButton: PPButton = {
        return PPButton(style: .primary, text: "그만하기")
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
private extension CommentCheckView {

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

        buttonStackView.addArrangedSubview(continueButton)
        buttonStackView.addArrangedSubview(stopButton)
        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
//            make.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}
