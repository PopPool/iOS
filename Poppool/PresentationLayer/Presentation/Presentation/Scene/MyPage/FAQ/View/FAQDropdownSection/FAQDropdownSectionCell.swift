//
//  FAQDropdownSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/13/25.
//

import UIKit

import RxSwift
import SnapKit

final class FAQDropdownSectionCell: UICollectionViewCell {

    // MARK: - Components
    let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()

    let listContentButton = UIButton()

    let qLabel: UILabel = {
        let label = UILabel()
        label.setLineHeightText(text: "Q", font: .engFont(style: .bold, size: 16), lineHeight: 1)
        label.textColor = .blu500
        return label
    }()

    let titleLabel: UILabel = {
        return UILabel()
    }()

    let dropDownImageView: UIImageView = {
        return UIImageView()
    }()

    let dropContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .pb4
        return view
    }()

    let dropContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
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
private extension FAQDropdownSectionCell {
    func setUpConstraints() {
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        listContentButton.snp.makeConstraints { make in
            make.height.equalTo(59).priority(.high)
        }
        listContentButton.addSubview(qLabel)
        qLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        listContentButton.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(qLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        listContentButton.addSubview(dropDownImageView)
        dropDownImageView.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }

        dropContentView.addSubview(dropContentLabel)
        dropContentLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(44)
            make.trailing.equalToSuperview().inset(20)
        }
        contentStackView.addArrangedSubview(listContentButton)
        contentStackView.addArrangedSubview(dropContentView)
    }
}

extension FAQDropdownSectionCell: Inputable {
    struct Input {
        var title: String?
        var content: String?
        var isOpen: Bool
    }

    func injection(with input: Input) {
        titleLabel.setLineHeightText(text: input.title, font: .korFont(style: .medium, size: 14))
        dropContentLabel.setLineHeightText(text: input.content, font: .korFont(style: .regular, size: 14), lineHeight: 1.5)
        dropContentLabel.lineBreakStrategy = .hangulWordPriority
        dropContentLabel.textColor = .g600
        if input.isOpen {
            dropDownImageView.image = UIImage(named: "icon_dropdown_bottom_g300")
            dropDownImageView.tintColor = .g300
            dropContentView.isHidden = false
        } else {
            dropDownImageView.image = UIImage(named: "icon_dropdown_top_g300")
            dropDownImageView.tintColor = .g300
            dropContentView.isHidden = true
        }
    }
}
