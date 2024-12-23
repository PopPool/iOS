//
//  TagSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit
import RxSwift

final class TagSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 13)
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
private extension TagSectionCell {
    func setUpConstraints() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 18
        contentView.layer.borderColor = UIColor.g200.cgColor
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14).priority(.high)
            make.center.equalToSuperview()
        }
    }
}

extension TagSectionCell: Inputable {
    struct Input {
        var title: String?
        var isSelected: Bool
        var id: Int64?
    }
    
    func injection(with input: Input) {
        titleLabel.text = input.title
        if input.isSelected {
            contentView.backgroundColor = .blu500
            contentView.layer.borderWidth = 0
            titleLabel.textColor = .w100
            titleLabel.font = . KorFont(style: .medium, size: 13)
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.borderWidth = 1
            titleLabel.textColor = .g400
            titleLabel.font = . KorFont(style: .medium, size: 13)
        }
    }
}
