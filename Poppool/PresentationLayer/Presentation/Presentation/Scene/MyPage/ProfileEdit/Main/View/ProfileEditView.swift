import UIKit

import DesignSystem

import SnapKit

final class ProfileEditView: UIView {

    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "프로필 설정", font: .korFont(style: .regular, size: 15))
        return view
    }()
    let saveButton: PPButton = {
        return PPButton(style: .primary, text: "저장", disabledText: "저장")
    }()

    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()

    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 48
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.g100.cgColor
        view.clipsToBounds = true
        return view
    }()
    let profileImageButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = .w100
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        return button
    }()
    private let profileImageButtonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "camera.fill")
        view.tintColor = .blu500
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let nickNameTitleLabel: PPLabel = {
        return PPLabel(style: .regular, fontSize: 13, text: "별명")
    }()
    let nickNameTextFieldTrailingView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        view.alignment = .center
        view.distribution = .fill
        view.layer.cornerRadius = 4
        view.layer.borderColor = UIColor.g200.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .w100
        return view
    }()
    let nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "별명을 입력해주세요"
        textField.font = .korFont(style: .medium, size: 14)
        return textField
    }()
    let nickNameClearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_clear_button"), for: .normal)
        button.isHidden = true
        return button
    }()
    let nickNameTextDescriptionLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12)
        label.text = "temptemp"
        return label
    }()
    let nickNameTextCountLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12)
        label.text = "0/10자"
        label.textColor = .g500
        return label
    }()
    let nickNameDuplicatedCheckButton: UIButton = {
        let button = UIButton()
        let title = "중복체크"
        // 밑줄 및 폰트 스타일 설정
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.korFont(style: .regular, size: 13), // 폰트
                .underlineStyle: NSUnderlineStyle.single.rawValue,  // 밑줄 스타일
                .foregroundColor: UIColor.g1000 // 텍스트 색상
            ]
        )
        let disabledAttributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.korFont(style: .regular, size: 13), // 폰트
                .underlineStyle: NSUnderlineStyle.single.rawValue,  // 밑줄 스타일
                .foregroundColor: UIColor.g300 // 텍스트 색상
            ]
        )
        // 버튼에 Attributed Title 적용
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setAttributedTitle(disabledAttributedTitle, for: .disabled)
        return button
    }()

    private let introTitleLabel: PPLabel = {
        return PPLabel(style: .regular, fontSize: 13, text: "자기소개")
    }()
    let introTextTrailingView: UIView = {
        let view = UIView()
        view.backgroundColor = .w100
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.g200.cgColor
        return view
    }()
    let introTextView: UITextView = {
        let view = UITextView()
        view.textContainerInset = .zero
        view.contentInset = .zero
        view.font = .korFont(style: .medium, size: 14)
        return view
    }()
    let introTextCountLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12)
        label.text = "0/10자"
        label.textColor = .g500
        return label
    }()
    let introDescriptionLabel: PPLabel = {
        return PPLabel(style: .medium, fontSize: 12)
    }()
    let introPlaceHolderLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "자기소개를 입력해주세요")
        label.textColor = .g200
        return label
    }()

    private let customInfoTitlelabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 16, text: "맞춤정보")
    }()

    let categoryButton: ProfileEditListButton = {
        let button = ProfileEditListButton()
        button.mainTitleLabel.setLineHeightText(text: "관심 카테고리", font: .korFont(style: .regular, size: 15))
        return button
    }()

    let infoButton: ProfileEditListButton = {
        let button = ProfileEditListButton()
        button.mainTitleLabel.setLineHeightText(text: "사용자 정보", font: .korFont(style: .regular, size: 15))
        return button
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
private extension ProfileEditView {

    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(saveButton.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        setUpProfileImageView()
        setUpNickNameView()
        setUpIntroView()
        setUpCustomInfoView()
    }

    func setUpProfileImageView() {
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(96)
            make.top.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
        }
        contentView.addSubview(profileImageButton)
        profileImageButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.trailing.bottom.equalTo(profileImageView)
        }
        profileImageButton.addSubview(profileImageButtonImageView)
        profileImageButtonImageView.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.center.equalToSuperview()
        }
    }

    func setUpNickNameView() {
        contentView.addSubview(nickNameTitleLabel)
        nickNameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(53)
            make.leading.equalToSuperview().inset(20)
        }
        nickNameClearButton.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        nickNameTextField.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        contentView.addSubview(nickNameTextFieldTrailingView)
        nickNameTextFieldTrailingView.addArrangedSubview(nickNameTextField)
        nickNameTextFieldTrailingView.addArrangedSubview(nickNameDuplicatedCheckButton)
        nickNameTextFieldTrailingView.addArrangedSubview(nickNameClearButton)
        nickNameTextFieldTrailingView.snp.makeConstraints { make in
            make.top.equalTo(nickNameTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        contentView.addSubview(nickNameTextDescriptionLabel)
        nickNameTextDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameTextFieldTrailingView.snp.bottom).offset(6)
            make.leading.equalToSuperview().inset(24)
        }
        contentView.addSubview(nickNameTextCountLabel)
        nickNameTextCountLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameTextFieldTrailingView.snp.bottom).offset(6)
            make.trailing.equalToSuperview().inset(24)
        }
    }

    func setUpIntroView() {
        contentView.addSubview(introTitleLabel)
        introTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameTextCountLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(20)
        }
        contentView.addSubview(introTextTrailingView)
        introTextTrailingView.snp.makeConstraints { make in
            make.top.equalTo(introTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        introTextTrailingView.addSubview(introTextView)
        introTextView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(16)
            make.height.equalTo(70)
        }
        introTextTrailingView.addSubview(introTextCountLabel)
        introTextCountLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(16)
        }
        introTextTrailingView.addSubview(introDescriptionLabel)
        introDescriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(introTextCountLabel)
            make.leading.equalToSuperview().inset(20)
        }
        introTextTrailingView.addSubview(introPlaceHolderLabel)
        introPlaceHolderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(20)
        }
    }

    func setUpCustomInfoView() {
        contentView.addSubview(customInfoTitlelabel)
        customInfoTitlelabel.snp.makeConstraints { make in
            make.top.equalTo(introTextTrailingView.snp.bottom).offset(27)
            make.leading.equalToSuperview().inset(20)
        }

        contentView.addSubview(categoryButton)
        categoryButton.snp.makeConstraints { make in
            make.top.equalTo(customInfoTitlelabel.snp.bottom).offset(32)
            make.leading.equalToSuperview().inset(22)
            make.trailing.equalToSuperview().inset(20)
        }

        contentView.addSubview(infoButton)
        infoButton.snp.makeConstraints { make in
            make.top.equalTo(categoryButton.snp.bottom).offset(32)
            make.leading.equalToSuperview().inset(22)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(56)
        }
    }
}
