//
//  BlockUserManageView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import UIKit

import SnapKit

final class BlockUserManageView: UIView {

    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "차단한 사용자 관리", font: .korFont(style: .regular, size: 15))
        return view
    }()

    let contentCollectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: .init())
    }()

    let emptyLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "차단한 사용자가 없어요")
        label.textColor = .g400
        return label
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
private extension BlockUserManageView {

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

        self.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(137)
            make.centerX.equalToSuperview()
        }
    }
}
