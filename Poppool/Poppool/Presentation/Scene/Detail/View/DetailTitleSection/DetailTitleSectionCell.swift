//
//  DetailTitleSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/10/24.
//

import UIKit

import RxSwift
import SnapKit

final class DetailTitleSectionCell: UICollectionViewCell {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18)
        label.numberOfLines = 2
        return label
    }()

    let bookMarkButton: UIButton = {
        return UIButton()
    }()

    let sharedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_shared"), for: .normal)
        return button
    }()

    var disposeBag = DisposeBag()
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
private extension DetailTitleSectionCell {
    func setUpConstraints() {
        contentView.addSubview(sharedButton)
        sharedButton.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.top.trailing.equalToSuperview()
        }

        contentView.addSubview(bookMarkButton)
        bookMarkButton.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.top.equalToSuperview()
            make.trailing.equalTo(sharedButton.snp.leading).offset(-4)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(bookMarkButton.snp.leading)
            make.bottom.equalToSuperview()
        }
    }
}

extension DetailTitleSectionCell: Inputable {
    struct Input {
        var title: String?
        var isBookMark: Bool
        var isLogin: Bool
    }

    func injection(with input: Input) {
        let bookMarkImage = input.isBookMark ? UIImage(named: "icon_bookmark_blue") : UIImage(named: "icon_bookmark_gray")
        bookMarkButton.setImage(bookMarkImage, for: .normal)
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 18))
        bookMarkButton.isHidden = !input.isLogin
    }
}
