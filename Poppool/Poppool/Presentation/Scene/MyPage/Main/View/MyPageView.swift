//
//  MyPageView.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/30/24.
//

import UIKit

import SnapKit

final class MyPageView: UIView {
    
    // MARK: - Components
    let contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.contentInsetAdjustmentBehavior = .never
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
private extension MyPageView {
    
    func setUpConstraints() {
        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
