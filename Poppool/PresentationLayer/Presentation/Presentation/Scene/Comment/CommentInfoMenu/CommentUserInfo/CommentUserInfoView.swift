import UIKit

import DesignSystem

import SnapKit

final class CommentUserInfoView: UIView {

    // MARK: - Components
    let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18)
        label.setLineHeightText(text: "님에 대해 더 알아보기", font: .korFont(style: .bold, size: 18))
        return label
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        return button
    }()

    let normalCommentButton: UIButton = {
        let button = UIButton()
        button.setTitle("코멘트를 작성한 팝업 모두보기", for: .normal)
        button.setTitleColor(.g1000, for: .normal)
        button.titleLabel?.font = .korFont(style: .medium, size: 15)
        button.contentHorizontalAlignment = .leading
        return button
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .g50
        return view
    }()

    let instaCommentButton: UIButton = {
        let button = UIButton()
        button.setTitle("이 유저 차단하기", for: .normal)
        button.setTitleColor(.g1000, for: .normal)
        button.titleLabel?.font = .korFont(style: .medium, size: 15)
        button.contentHorizontalAlignment = .leading
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
private extension CommentUserInfoView {

    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(32)
            make.leading.equalToSuperview().inset(20)
        }

        self.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
        }

        self.addSubview(normalCommentButton)
        normalCommentButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(57)
        }

        self.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(normalCommentButton.snp.bottom)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(instaCommentButton)
        instaCommentButton.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(57)
        }
    }
}
