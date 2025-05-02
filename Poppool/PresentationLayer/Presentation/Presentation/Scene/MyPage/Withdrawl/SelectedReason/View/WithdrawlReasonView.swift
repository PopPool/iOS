import UIKit

import DesignSystem

import SnapKit

final class WithdrawlReasonView: UIView {

    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "회원 탈퇴", font: .korFont(style: .regular, size: 15))
        return view
    }()

    private let titleLabel: UILabel = {
        let text = "탈퇴하려는 이유가\n무엇인가요?"
        let label = UILabel()
        label.setLineHeightText(text: text, font: .korFont(style: .bold, size: 20), lineHeight: 1.312)
        label.numberOfLines = 2
        return label
    }()

    private let descriptionLabel: PPLabel = {
        let text = "알려주시는 내용을 참고해 더 나은 팝풀을\n만들어볼게요."
        let label = PPLabel(style: .regular, fontSize: 15, text: text)
        label.textColor = .g600
        label.numberOfLines = 2
        label.setLineHeightText(text: text, font: .korFont(style: .regular, size: 15), lineHeight: 1.4)
        return label
    }()

    let skipButton: PPButton = {
        let button = PPButton(style: .secondary, text: "건너뛰기")
        button.setBackgroundColor(.w100, for: .normal)
        return button
    }()

    let checkButton: PPButton = {
        return PPButton(style: .primary, text: "확인", disabledText: "확인")
    }()

    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 12
        return view
    }()

    let contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.backgroundColor = .g50
        return view
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
private extension WithdrawlReasonView {

    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(64)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        buttonStackView.addArrangedSubview(skipButton)
        buttonStackView.addArrangedSubview(checkButton)

        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonStackView.snp.top)
        }
    }
}
