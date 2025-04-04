//
//  MyPageBookmarkView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import UIKit

import SnapKit

final class MyPageBookmarkView: UIView {

    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "찜한 팝업", font: .korFont(style: .regular, size: 15))
        return view
    }()

    let contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.backgroundColor = .g50
//        view.isScrollEnabled = false
        view.isPrefetchingEnabled = true
        return view
    }()

    let emptyLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "앗! 아직 찜해둔 팝업이 없어요")
        label.textColor = .g400
        label.isHidden = true
        return label
    }()

    let countButtonView: CountButtonView = {
        return CountButtonView()
    }()

    let emptyButton: UIButton = {
        let button = UIButton()
        let buttonTitle = NSAttributedString(
            string: "추천 팝업 보러가기",
            attributes: [
                .font: UIFont.korFont(style: .regular, size: 13)!,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.g1000
            ]
        )
        button.setAttributedTitle(buttonTitle, for: .normal)
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
private extension MyPageBookmarkView {

    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        self.addSubview(countButtonView)
        countButtonView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(22)
        }
        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(countButtonView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }

        self.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(245)
        }

        self.addSubview(emptyButton)
        emptyButton.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel.snp.bottom).offset(26)
            make.centerX.equalToSuperview()
        }
    }
}
