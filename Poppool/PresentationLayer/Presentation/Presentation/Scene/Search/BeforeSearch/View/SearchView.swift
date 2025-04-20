//
//  SearchView.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/4/24.
//

import UIKit

import SnapKit

final class SearchView: UIView {

    // MARK: - Components
    let contentCollectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: .init())
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
private extension SearchView {

    func setUpConstraints() {
        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
