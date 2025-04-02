//
//  DetailCommentTitleSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/18/24.
//

import UIKit

import RxSwift
import SnapKit

final class DetailCommentTitleSectionCell: UICollectionViewCell {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 16, text: "이 팝업에 대한 코멘트")
    }()

    private let countLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.textColor = .g600
        return label
    }()

    let totalViewButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(
            string: "전체보기",
            attributes: [
                .font: UIFont.KorFont(style: .regular, size: 13)!,  // 커스텀 폰트 적용
                .underlineStyle: NSUnderlineStyle.single.rawValue // 밑줄 스타일
            ]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
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
private extension DetailCommentTitleSectionCell {
    func setUpConstraints() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.bottom.equalToSuperview()
        }

        contentView.addSubview(totalViewButton)
        totalViewButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

extension DetailCommentTitleSectionCell: Inputable {
    struct Input {
        var commentCount: Int64
        var buttonIsHidden: Bool = false
    }

    func injection(with input: Input) {
        countLabel.setLineHeightText(text: "총 \(input.commentCount)개", font: .KorFont(style: .regular, size: 13))
        totalViewButton.isHidden = input.buttonIsHidden
    }
}
