//
//  SearchTitleSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/4/24.
//

import UIKit

import RxSwift
import SnapKit

final class SearchTitleSectionCell: UICollectionViewCell {

    // MARK: - Components

    var disposeBag = DisposeBag()

    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .KorFont(style: .bold, size: 16)
        return label
    }()

    let titleButton: UIButton = {
        return UIButton()
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
private extension SearchTitleSectionCell {
    func setUpConstraints() {
        self.addSubview(sectionTitleLabel)
        sectionTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }

        self.addSubview(titleButton)
        titleButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
    }
}

extension SearchTitleSectionCell: Inputable {
    struct Input {
        var title: String?
        var buttonTitle: String?
    }

    func injection(with input: Input) {
        sectionTitleLabel.text = input.title
        if let buttonTitle = input.buttonTitle {
            titleButton.isHidden = false
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.KorFont(style: .regular, size: 13)!
            ]
            let attributedTitle = NSAttributedString(string: buttonTitle, attributes: attributes)
            titleButton.setAttributedTitle(attributedTitle, for: .normal)
        } else {
            titleButton.isHidden = true
        }
    }
}
