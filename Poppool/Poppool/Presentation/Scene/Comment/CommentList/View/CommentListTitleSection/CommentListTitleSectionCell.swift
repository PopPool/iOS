//
//  CommentListTitleSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import SnapKit
import RxSwift

final class CommentListTitleSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    private let countLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.textColor = .g400
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
private extension CommentListTitleSectionCell {
    func setUpConstraints() {
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CommentListTitleSectionCell: Inputable {
    struct Input {
        var count: Int
    }
    
    func injection(with input: Input) {
        countLabel.setLineHeightText(text: "총 \(input.count)건", font: .KorFont(style: .regular, size: 13))
    }
}
