//
//  SearchResultView.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/7/24.
//

import UIKit

import SnapKit

final class SearchResultView: UIView {
    
    // MARK: - Components
    let contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        return view
    }()
    
    let emptyLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "검색 결과가 없어요:(\n다른 키워드로 검색해주세요")
        label.textAlignment = .center
        label.numberOfLines = 2
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
private extension SearchResultView {
    
    func setUpConstraints() {
        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(contentCollectionView.snp.top).inset(193)
            make.leading.trailing.equalToSuperview()
        }
    }
}
