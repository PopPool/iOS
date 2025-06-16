import UIKit

import DesignSystem

import SnapKit

final class CommentSelectedView: UIView {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18)
        label.setLineHeightText(text: "코멘트 작성 방법 선택", font: .korFont(style: .bold, size: 18))
        return label
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        return button
    }()

    let normalCommentButton: UIButton = {
        let button = UIButton()
        button.setTitle("일반 코멘트 작성하기", for: .normal)
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
        button.setTitle("인스타그램 연동 코멘트 작성하기", for: .normal)
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
private extension CommentSelectedView {

    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(34)
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
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(normalCommentButton.snp.bottom).offset(16)
            make.height.equalTo(2)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(instaCommentButton)
        instaCommentButton.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}
