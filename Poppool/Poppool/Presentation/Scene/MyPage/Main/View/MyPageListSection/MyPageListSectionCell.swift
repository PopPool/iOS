//
//  MyPageListSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/2/25.
//

import UIKit

import SnapKit
import RxSwift

final class MyPageListSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    let titleLabel = UILabel()
    
    private let rightImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_right_gray")
        return view
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let disposeBag = DisposeBag()
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - SetUp
private extension MyPageListSectionCell {
    func setUpConstraints() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        contentView.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
    }
}

extension MyPageListSectionCell: Inputable {
    struct Input {
        var title: String?
        var subTitle: String?
    }
    
    func injection(with input: Input) {
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .regular, size: 15))
        
        if input.subTitle == nil {
            rightImageView.isHidden = false
            subTitleLabel.isHidden = true
        } else {
            rightImageView.isHidden = true
            subTitleLabel.isHidden = false
            subTitleLabel.setLineHeightText(text: input.subTitle, font: .KorFont(style: .regular, size: 13))
            subTitleLabel.textColor = . blu500
        }
    }
}
