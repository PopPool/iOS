//
//  CommentDetailContentSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import RxSwift
import SnapKit

final class CommentDetailContentSectionCell: UICollectionViewCell {

    // MARK: - Components

    private let contentLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 13)
        label.numberOfLines = 0
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
private extension CommentDetailContentSectionCell {
    func setUpConstraints() {
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CommentDetailContentSectionCell: Inputable {
    struct Input {
        var content: String?
    }

    func injection(with input: Input) {
        contentLabel.setLineHeightText(text: input.content, font: .korFont(style: .medium, size: 13))
    }
}
