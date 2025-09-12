import UIKit

import DesignSystem

import SnapKit
import Then

final class AgeSelectedButton: UIView {

    // MARK: - Components
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        return view
    }()

    private let defaultLabel = PPLabel(text: "나이를 선택해주세요", style: .KOm14).then {
        $0.textColor = .g400
    }

    private let rightImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_dropdown")
        return view
    }()

    private let ageTitleLabel = PPLabel(text: "나이", style: .KOm11).then {
        $0.textColor = .g400
    }

    private let ageLabel = PPLabel(style: .KOm14).then {
        $0.textColor = .g1000
    }

    private let verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.isHidden = true
        view.spacing = 4
        return view
    }()

    let button: UIButton = {
        return UIButton()
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
private extension AgeSelectedButton {

    func setUpConstraints() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor.g200.cgColor

        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        rightImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        verticalStackView.addArrangedSubview(ageTitleLabel)
        verticalStackView.addArrangedSubview(ageLabel)

        contentStackView.addArrangedSubview(defaultLabel)
        contentStackView.addArrangedSubview(verticalStackView)
        contentStackView.addArrangedSubview(rightImageView)

        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AgeSelectedButton: Inputable {
    struct Input {
        var age: Int?
    }

    func injection(with input: Input) {
        if let age = input.age {
            verticalStackView.isHidden = false
            ageLabel.updateText(to: "\(age)세")
            defaultLabel.isHidden = true
        } else {
            verticalStackView.isHidden = true
            defaultLabel.isHidden = false
        }
    }
}
