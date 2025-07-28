import UIKit

import SnapKit

public final class PPCancelHeaderView: UIView {

    // MARK: - Components
    public let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_backButton"), for: .normal)
        button.tintColor = .black
        return button
    }()

    public let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setText(to: "취소", with: .KOr14, for: .normal)
        return button
    }()

    // MARK: - init
    public init() {
        super.init(frame: .zero)
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension PPCancelHeaderView {

    func setUpConstraints() {
        self.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(12)
        }

        self.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().inset(20)
        }
    }
}
