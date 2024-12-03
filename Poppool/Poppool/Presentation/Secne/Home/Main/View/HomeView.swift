//
//  HomeView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/28/24.
//

import UIKit

import SnapKit

final class HomeView: UIView {
    
    // MARK: - Components
    let contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.contentInsetAdjustmentBehavior = .never
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
private extension HomeView {
    
    func setUpConstraints() {
        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
