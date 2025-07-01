import UIKit

import DesignSystem

import SnapKit

final class CountButtonView: UIView {

    // MARK: - Components
    let countLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.textColor = .g400
        return label
    }()

    private let dropDownImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_dropdown")
        return view
    }()

    let buttonTitleLabel: UILabel = {
        return UILabel()
    }()

    let dropdownButton: UIButton = {
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
private extension CountButtonView {

    func setUpConstraints() {
        self.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        dropdownButton.addSubview(dropDownImageView)
        dropDownImageView.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.top.trailing.bottom.equalToSuperview()
        }

        dropdownButton.addSubview(buttonTitleLabel)
        buttonTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(dropDownImageView.snp.leading).offset(-6)
            make.centerY.equalToSuperview()
        }

        self.addSubview(dropdownButton)
        dropdownButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
