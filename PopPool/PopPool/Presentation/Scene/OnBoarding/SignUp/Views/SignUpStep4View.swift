//
//  SignUpStep4View.swift
//  PopPool
//
//  Created by SeoJunYoung on 6/27/24.
//

import UIKit
import SnapKit

final class SignUpStep4View: UIStackView {
    
    // MARK: - Components
    private let topSpacingView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "해당되시는 성별 / 나이대를 알려주세요"
        label.font = .KorFont(style: .bold, size: 16)
        label.textColor = .g1000
        return label
    }()
    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "가장 잘 맞는 팝업스토어를 소개해드릴게요."
        label.font = .KorFont(style: .regular, size: 12)
        label.textColor = .g1000
        return label
    }()
    private let subLabelBottomspacingView = UIView()
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.textColor = .g1000
        label.font = .KorFont(style: .regular, size: 13)
        return label
    }()
    private let genderLabelBottomspacingView = UIView()
    let genderSegmentedControl: SegmentedControlCPNT = SegmentedControlCPNT(
        type: .base,
        segments: ["남성", "여성", "선택안함"],
        selectedSegmentIndex: 2
    )
    private let genderSegmentedControlBottomSpacingView = UIView()
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "나이"
        label.textColor = .g1000
        label.font = .KorFont(style: .regular, size: 13)
        return label
    }()
    private let ageLabelBottomSpacingView = UIView()
    let ageButton = SignUpAgeSelectedButton()
    private let bottomSpacingView = UIView()
    
    init() {
        super.init(frame: .zero)
        setUp()
        setUpConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension SignUpStep4View {
    
    // 기본 설정
    func setUp() {
        self.axis = .vertical
    }
    
    // 뷰 제약 설정
    func setUpConstraints() {
        topSpacingView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide._36px)
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        subLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        subLabelBottomspacingView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide._36px)
        }
        genderLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        genderLabelBottomspacingView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide._8px)
        }
        genderSegmentedControlBottomSpacingView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide._36px)
        }
        ageLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        ageLabelBottomSpacingView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide._8px)
        }
        ageButton.snp.makeConstraints { make in
            make.height.equalTo(72)
        }
        self.addArrangedSubview(topSpacingView)
        self.addArrangedSubview(titleLabel)
        self.addArrangedSubview(subLabel)
        self.addArrangedSubview(subLabelBottomspacingView)
        self.addArrangedSubview(genderLabel)
        self.addArrangedSubview(genderLabelBottomspacingView)
        self.addArrangedSubview(genderSegmentedControl)
        self.addArrangedSubview(genderSegmentedControlBottomSpacingView)
        self.addArrangedSubview(ageLabel)
        self.addArrangedSubview(ageLabelBottomSpacingView)
        self.addArrangedSubview(ageButton)
        self.addArrangedSubview(bottomSpacingView)
    }
}
