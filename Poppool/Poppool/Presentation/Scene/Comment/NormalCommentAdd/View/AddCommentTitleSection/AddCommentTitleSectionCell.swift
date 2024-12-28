//
//  AddCommentTitleSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/14/24.
//

import UIKit

import SnapKit
import RxSwift

final class AddCommentTitleSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    let disposeBag = DisposeBag()
    
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 16)
        return label
    }()
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
private extension AddCommentTitleSectionCell {
    func setUpConstraints() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AddCommentTitleSectionCell: Inputable {
    struct Input {
        var title: String?
    }
    
    func injection(with input: Input) {
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 16))
    }
}
