import UIKit

import DesignSystem

import SnapKit

final class SignUpStep3View: UIView {

    // MARK: - Components
    let nickNameLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 20)
        label.textColor = .blu500
        label.text = "하이"
        return label
    }()

    private let titleTopLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 20)
        label.text = "님에 대해"
        return label
    }()

    private let titleBottomLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 20)
        label.text = "조금 더 알려주시겠어요?"
        return label
    }()

    private let subTitleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 16)
        label.text = "관심이 있는 카테고리를 선택해주세요"
        return label
    }()

    private let subTitleDescriptionLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12)
        label.text = "최대 5개까지 선택할 수 있어요."
        return label
    }()

    let categoryCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.isScrollEnabled = false
        return view
    }()

    let skipButton: PPButton = {
        return PPButton(style: .secondary, text: "건너뛰기")
    }()

    let completeButton: PPButton = {
        return PPButton(style: .primary, text: "다음", disabledText: "다음")
    }()

    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 12
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

    func setNickName(nickName: String?) {
        nickNameLabel.text = nickName
    }
}

// MARK: - SetUp
private extension SignUpStep3View {

    func setUpConstraints() {
        self.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(64)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }

        self.addSubview(titleTopLabel)
        titleTopLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel)
            make.leading.equalTo(nickNameLabel.snp.trailing)
            make.height.equalTo(28)
        }

        self.addSubview(titleBottomLabel)
        titleBottomLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTopLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }

        self.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleBottomLabel.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(22)
        }

        self.addSubview(subTitleDescriptionLabel)
        subTitleDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(18)
        }

        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        buttonStackView.addArrangedSubview(skipButton)
        buttonStackView.addArrangedSubview(completeButton)

        self.addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(subTitleDescriptionLabel.snp.bottom).offset(36)
            make.bottom.equalTo(buttonStackView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
    }
}
