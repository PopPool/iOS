//
//  AddCommentSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import SnapKit
import RxSwift

final class AddCommentSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    var disposeBag = DisposeBag()
    
    let commentTextView: UITextView = {
        let view = UITextView()
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.font = .KorFont(style: .medium, size: 14)
        return view
    }()
    
    let countLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12)
        label.textColor = .g500
        return label
    }()
    
    private let placeHolderLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "최소 10자 이상 입력해주세요")
        label.textColor = .g200
        return label
    }()
    
    private let noticeLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 12, text: "최대 500자까지 입력해주세요")
        label.textColor = .re500
        label.isHidden = true
        return label
    }()
    
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
        bind()
    }
}

// MARK: - SetUp
private extension AddCommentSectionCell {
    func bind() {
        commentTextView.rx.didChange
            .debounce(.milliseconds(5), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { (owner, _) in
                let text = owner.commentTextView.text ?? ""
                switch text.count {
                case 0:
                    owner.countLabel.text = "0 / 500자"
                    owner.placeHolderLabel.isHidden = false
                    owner.noticeLabel.isHidden = true
                    owner.contentView.layer.borderColor = UIColor.g100.cgColor
                    owner.countLabel.textColor = .g500
                    owner.commentTextView.textColor = .g1000
                case 1...500:
                    owner.countLabel.text = "\(text.count) / 500자"
                    owner.placeHolderLabel.isHidden = true
                    owner.noticeLabel.isHidden = true
                    owner.contentView.layer.borderColor = UIColor.g100.cgColor
                    owner.countLabel.textColor = .g500
                    owner.commentTextView.textColor = .g1000
                default:
                    owner.countLabel.text = "\(text.count) / 500자"
                    owner.placeHolderLabel.isHidden = true
                    owner.noticeLabel.isHidden = false
                    owner.contentView.layer.borderColor = UIColor.re500.cgColor
                    owner.countLabel.textColor = .re500
                    owner.commentTextView.textColor = .re500
                }
            }
            .disposed(by: disposeBag)
            
    }
    func setUpConstraints() {
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        contentView.layer.borderColor = UIColor.g100.cgColor
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = .w100
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }
        contentView.addSubview(commentTextView)
        commentTextView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(countLabel.snp.top).offset(-4)
        }
        contentView.addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        contentView.addSubview(noticeLabel)
        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}

extension AddCommentSectionCell: Inputable {
    struct Input {
    }
    
    func injection(with input: Input) {
    }
}
