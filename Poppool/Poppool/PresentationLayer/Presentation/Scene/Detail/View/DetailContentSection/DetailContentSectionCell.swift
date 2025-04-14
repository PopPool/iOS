//
//  DetailContentSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/10/24.
//

import UIKit

import RxSwift
import SnapKit

final class DetailContentSectionCell: UICollectionViewCell {

    // MARK: - Components

    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 16
        return view
    }()
    let contentLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.numberOfLines = 3
        return label
    }()

    let dropDownButton: UIButton = {
        return UIButton()
    }()

    let buttonTitleLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 13, text: "더보기")
        label.textColor = .g600
        return label
    }()

    let buttonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_dropdown_bottom_gray")
        return view
    }()

    var isOpen: Bool = false

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
private extension DetailContentSectionCell {
    func setUpConstraints() {
        dropDownButton.addSubview(buttonTitleLabel)
        buttonTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        contentLabel.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width - 40)
        }
        dropDownButton.addSubview(buttonImageView)
        buttonImageView.snp.makeConstraints { make in
            make.size.equalTo(14)
            make.trailing.equalToSuperview()
            make.leading.equalTo(buttonTitleLabel.snp.trailing).offset(3)
            make.centerY.equalToSuperview()
        }
        contentStackView.addArrangedSubview(contentLabel)
        contentStackView.addArrangedSubview(dropDownButton)
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension DetailContentSectionCell: Inputable {
    struct Input {
        var content: String?
    }

    func injection(with input: Input) {
        let text = input.content ?? ""
        contentLabel.setLineHeightText(text: text, font: .korFont(style: .regular, size: 13))
        if text.count >= 68 {
            dropDownButton.isHidden = false
        } else {
            dropDownButton.isHidden = true
        }
    }
}
