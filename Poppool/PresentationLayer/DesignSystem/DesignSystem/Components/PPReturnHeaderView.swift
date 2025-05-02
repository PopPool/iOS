import UIKit

import SnapKit

public final class PPReturnHeaderView: UIView {

    // MARK: - Components
    public let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_backButton"), for: .normal)
        button.tintColor = .black
        return button
    }()

    public let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .korFont(style: .regular, size: 15)
        label.textColor = .g1000
        return label
    }()

    // MARK: - init
    public init() {
        super.init(frame: .zero)
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        headerLabel.text = text
    }
}

// MARK: - SetUp
private extension PPReturnHeaderView {

    func setUpConstraints() {
        self.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(12)
            make.size.equalTo(28)
        }

        self.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
    }
}
