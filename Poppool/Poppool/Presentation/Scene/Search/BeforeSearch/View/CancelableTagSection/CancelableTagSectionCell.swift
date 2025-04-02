//
//  CancelableTagSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/4/24.
//

import UIKit

import RxSwift
import SnapKit

final class CancelableTagSectionCell: UICollectionViewCell {

    // MARK: - Components

    var disposeBag = DisposeBag()

    private let titleLabel: PPLabel = {
        return PPLabel(style: .medium, fontSize: 11)
    }()

    let cancelButton: UIButton = {
        return UIButton()
    }()

    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.spacing = 2
        return view
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
private extension CancelableTagSectionCell {
    func setUpConstraints() {
        contentView.layer.cornerRadius = 15.5
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1

        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(8)
        }
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(cancelButton)

        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }
}

extension CancelableTagSectionCell: Inputable {
    struct Input {
        var title: String?
        var id: Int64? = nil
        var isSelected: Bool = false
        var isCancelAble: Bool = true
    }

    func injection(with input: Input) {
        let xmarkImage = input.isSelected ? UIImage(named: "icon_xmark_white") : UIImage(named: "icon_xmark_gray")
        cancelButton.setImage(xmarkImage, for: .normal)
        if input.isSelected {
            contentView.backgroundColor = .blu500
            titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 11), lineHeight: 1.15)
            titleLabel.textColor = .w100
            contentView.layer.borderColor = UIColor.blu500.cgColor
        } else {
            contentView.backgroundColor = .clear
            titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .medium, size: 11), lineHeight: 1.15)
            titleLabel.textColor = .g400
            contentView.layer.borderColor = UIColor.g200.cgColor
        }
        cancelButton.isHidden = !input.isCancelAble

        if input.isCancelAble {
            contentStackView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().inset(8)
            }
        } else {
            contentStackView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().inset(12)
            }
        }
    }
}
