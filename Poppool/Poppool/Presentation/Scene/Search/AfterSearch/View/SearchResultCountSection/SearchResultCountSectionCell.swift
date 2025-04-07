//
//  SearchResultCountSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/7/24.
//

import UIKit

import RxSwift
import SnapKit

final class SearchResultCountSectionCell: UICollectionViewCell {

    // MARK: - Components

    var disposeBag = DisposeBag()

    private let countLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.textColor = .g600
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

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - SetUp
private extension SearchResultCountSectionCell {
    func setUpConstraints() {
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension SearchResultCountSectionCell: Inputable {
    struct Input {
        var count: Int
    }

    func injection(with input: Input) {
        countLabel.text = "총 \(input.count)개를 찾았어요."
    }
}
