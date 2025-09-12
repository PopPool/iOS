import UIKit

import DesignSystem

import SnapKit
import Then

final class SignUpStep2View: UIView {

    // MARK: - Components
    private let titleLabel = PPLabel(text: "팝풀에서 사용할\n별명을 설정해볼까요?", style: .KOb20).then {
        $0.numberOfLines = 0
    }

    private let descriptionLabel = PPLabel(text: "이후 이 별명으로 팝풀에서 활동할 예정이에요.", style: .KOr15).then {
        $0.textColor = .g600
    }

    let completeButton = PPButton(buttonStyle: .primary, text: "확인", disabledText: "다음").then {
        $0.isEnabled = false
    }

    let textFieldTrailingView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        view.alignment = .center
        view.distribution = .equalSpacing
        view.layer.cornerRadius = 4
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "별명을 입력해주세요"
        textField.font = .korFont(style: .medium, size: 14)
        return textField
    }()

    let clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_clear_button"), for: .normal)
        return button
    }()

    let textDescriptionLabel = PPLabel(style: .KOr12)

    let textCountLabel = PPLabel(text: "0/10자", style: .KOr12).then {
        $0.textColor = .g500
    }

    let duplicatedCheckButton = PPUnderlinedTextButton(fontStyle: .KOr13, text: "중복체크")

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
private extension SignUpStep2View {

    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(64)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        self.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(textFieldTrailingView)
        textFieldTrailingView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        textFieldTrailingView.addArrangedSubview(textField)
        textFieldTrailingView.addArrangedSubview(duplicatedCheckButton)
        textFieldTrailingView.addArrangedSubview(clearButton)
        duplicatedCheckButton.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        clearButton.snp.makeConstraints { make in
            make.size.equalTo(16)
        }

        self.addSubview(textDescriptionLabel)
        textDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(textFieldTrailingView.snp.bottom).offset(6)
            make.leading.equalToSuperview().inset(24)
        }

        self.addSubview(textCountLabel)
        textCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(textDescriptionLabel)
            make.trailing.equalToSuperview().inset(24)
        }

        self.addSubview(completeButton)
        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(52)
        }

        textField.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }
}
