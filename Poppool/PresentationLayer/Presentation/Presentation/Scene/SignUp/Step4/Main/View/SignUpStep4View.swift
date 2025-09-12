import UIKit

import DesignSystem

import SnapKit
import Then

final class SignUpStep4View: UIView {

    // MARK: - Components
    private let nickNameLabel = PPLabel(style: .KOb20).then {
        $0.updateTextColor(to: .blu500)
    }

    private let titleTopLabel = PPLabel(text: "님에 대해", style: .KOb20)

    private let titleBottomLabel = PPLabel(text: "조금 더 알려주시겠어요?", style: .KOb20)

    private let subTitleLabel = PPLabel(text: "해당되시는 성별 / 나이대를 알려주세요", style: .KOb16)

    private let subTitleDescriptionLabel = PPLabel(text: "가장 잘 맞는 팝업스토어를 소개해드릴게요.", style: .KOr12)

    private let genderTitleLabel = PPLabel(text: "성별", style: .KOr13)

    let genderSegmentControl: PPSegmentedControl = {
        return PPSegmentedControl(
            type: .base,
            segments: ["남성", "여성", "선택안함"],
            selectedSegmentIndex: 2
        )
    }()

    private let ageTitleLabel = PPLabel(text: "나이", style: .KOr13)

    let ageSelectedButton: AgeSelectedButton = {
        return AgeSelectedButton()
    }()

    let skipButton: PPButton = {
        return PPButton(buttonStyle: .secondary, text: "건너뛰기")
    }()

    let completeButton: PPButton = {
        return PPButton(buttonStyle: .primary, text: "확인", disabledText: "확인")
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

    // FIXME: 회원 가입 과정에서 너무 많은 호출을 하고 있는 문제 수정
    /// 원래라면 attr을 유지하는 updateText 메서드를 이용해야 스타일이 유지되는데
    /// 여기는 오히려 text에 주입을 해줘야 스타일이 유지되고 있음
    /// 아마 다회 호출하는 과정에서 스타일 처리에 문제가 발생하는게 아닌가 싶음
    /// step3에 동일한 메서드 있으니 수정시 같이 수정
    func setNickName(nickName: String?) {
        nickNameLabel.text = nickName
    }
}

// MARK: - SetUp
private extension SignUpStep4View {

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

        self.addSubview(genderTitleLabel)
        genderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(subTitleDescriptionLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }

        self.addSubview(genderSegmentControl)
        genderSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(genderTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(ageTitleLabel)
        ageTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(genderSegmentControl.snp.bottom).offset(36)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }

        self.addSubview(ageSelectedButton)
        ageSelectedButton.snp.makeConstraints { make in
            make.top.equalTo(ageTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(72)
        }

        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        buttonStackView.addArrangedSubview(skipButton)
        buttonStackView.addArrangedSubview(completeButton)
    }
}
