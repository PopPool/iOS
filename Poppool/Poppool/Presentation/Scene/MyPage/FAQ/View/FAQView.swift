//
//  FAQView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/13/25.
//

import UIKit

import SnapKit

final class FAQView: UIView {

    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "고객문의", font: .KorFont(style: .regular, size: 15))
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
private extension FAQView {

    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
