//
//  InstaCommentAddView.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import SnapKit

final class InstaCommentAddView: UIView {

    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "코멘트 작성하기", font: .KorFont(style: .regular, size: 15))
        return view
    }()

    let instaButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .g900
        button.layer.cornerRadius = 4

        let title = "Instagram 열기"
        let attributedTitle = NSMutableAttributedString(string: title)

        let englishFont = UIFont.EngFont(style: .medium, size: 15)!
        attributedTitle.addAttribute(.font, value: englishFont, range: (title as NSString).range(of: "Instagram"))

        let koreanFont = UIFont.KorFont(style: .medium, size: 15)!
        attributedTitle.addAttribute(.font, value: koreanFont, range: (title as NSString).range(of: "열기"))

        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private let instaImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_instagram")
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
private extension InstaCommentAddView {

    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.addSubview(instaButton)
        instaButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        instaButton.addSubview(instaImageView)
        instaImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }

        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(instaButton.snp.top)
        }
    }
}
