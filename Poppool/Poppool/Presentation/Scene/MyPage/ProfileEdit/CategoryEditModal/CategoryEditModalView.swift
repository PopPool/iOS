//
//  CategoryEditModalView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/10/25.
//

import UIKit

import SnapKit

final class CategoryEditModalView: UIView {
    
    // MARK: - Components
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18, text: "관심 카테고리를 선택해주세요")
        return label
    }()
    
    let xmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        return button
    }()
    
    let contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.isScrollEnabled = false
        return view
    }()
    
    let saveButton: PPButton = {
        let button = PPButton(style: .primary, text: "저장", disabledText: "저장")
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
private extension CategoryEditModalView {
    
    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(32)
        }
        
        self.addSubview(xmarkButton)
        xmarkButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
        }
        
        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(195)
        }
        
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
