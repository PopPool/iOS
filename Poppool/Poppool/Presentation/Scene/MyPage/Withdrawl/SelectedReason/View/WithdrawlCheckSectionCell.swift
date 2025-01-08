//
//  WithdrawlCheckSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/7/25.
//

import UIKit

import SnapKit
import RxSwift

final class WithdrawlCheckSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    private let checkImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.textContainerInset = .zero
        view.contentInset = .zero
        view.font = .KorFont(style: .medium, size: 14)
        view.backgroundColor = .clear
        return view
    }()
    
    let cellButton: UIButton = UIButton()
    
    private let trailingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let textTrailingView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.g100.cgColor
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    private let placeHolderLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "탈퇴 이유를 입력해주세요")
        label.textColor = .g200
        return label
    }()
    
    var disposeBag = DisposeBag()
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
        bind()
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
private extension WithdrawlCheckSectionCell {
    func setUpConstraints() {
        cellButton.addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        cellButton.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkImageView.snp.trailing).offset(8)
            make.height.equalTo(22).priority(.high)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        contentView.addSubview(cellButton)
        cellButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(cellButton)
        contentStackView.addArrangedSubview(trailingView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        
        trailingView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }
        
        trailingView.addSubview(textTrailingView)
        textTrailingView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        textTrailingView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(70)
        }
        
        textTrailingView.addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(20)
        }
    }
    
    func bind() {
        textView.rx.text
            .withUnretained(self)
            .subscribe(onNext: { (owner, text) in
                let text = text ?? ""
                owner.placeHolderLabel.isHidden = !text.isEmpty
            })
            .disposed(by: disposeBag)
    }
}

extension WithdrawlCheckSectionCell: Inputable {
    struct Input {
        var isSelected: Bool
        var title: String?
        var id: Int64
        var text: String?
    }
    
    func injection(with input: Input) {
        let image = input.isSelected ? UIImage(named: "icon_check_fill") : UIImage(named: "icon_check")
        checkImageView.image = image
        let title = input.title ?? ""
        titleLabel.setLineHeightText(text: title, font: .KorFont(style: .regular, size: 14))
        bind()
        if input.isSelected {
            if title == "기타" {
                trailingView.isHidden = false
            } else { trailingView.isHidden = true }
        } else {
            trailingView.isHidden = true
        }
        textView.text = input.text
    }
}
