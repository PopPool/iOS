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
    let contentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    // MARK: - init
    init() {
        super.init(frame: .zero)

        self.addSubviews()
        self.setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension SearchView {

    func addSubviews() {
        [contentCollectionView].forEach {
            self.addSubview($0)
        }
    }

    func setUpConstraints() {
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
