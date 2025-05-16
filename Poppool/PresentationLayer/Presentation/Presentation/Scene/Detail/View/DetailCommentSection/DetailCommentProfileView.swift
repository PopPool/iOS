import UIKit

import DesignSystem

import SnapKit

final class DetailCommentProfileView: UIStackView {

    // MARK: - Components
    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 3
        return view
    }()

    let nickNameLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 13)
    }()

    let dateLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12)
        label.textColor = .g400
        return label
    }()

    let button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_comment_button"), for: .normal)
        return button
    }()

    let spacingView: UIView = UIView()
    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - SetUp
private extension DetailCommentProfileView {

    func setUpConstraints() {
        self.alignment = .center
        self.spacing = 12
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        button.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        contentStackView.addArrangedSubview(nickNameLabel)
        contentStackView.addArrangedSubview(dateLabel)
        self.addArrangedSubview(profileImageView)
        self.addArrangedSubview(contentStackView)
        self.addArrangedSubview(button)
    }
}
