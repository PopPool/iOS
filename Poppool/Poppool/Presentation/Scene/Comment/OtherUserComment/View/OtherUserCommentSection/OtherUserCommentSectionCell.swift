//
//  OtherUserCommentSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/28/24.
//

import UIKit

import SnapKit
import RxSwift

final class OtherUserCommentSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    private let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 11)
        label.textColor = .blu500
        return label
    }()
    
    private let contentLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 11)
        label.lineBreakMode = . byTruncatingTail
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 11)
        label.textColor = .g400
        return label
    }()
    
    private let likeImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_like_clear")
        return view
    }()
    
    private let likeCountLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 11)
        label.textColor = .w100
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
private extension OtherUserCommentSectionCell {
    func setUpConstraints() {
        contentView.backgroundColor = .w100
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(163.5)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(16)
        }

        
        imageView.addSubview(likeCountLabel)
        likeCountLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(12)
        }
        
        imageView.addSubview(likeImageView)
        likeImageView.snp.makeConstraints { make in
            make.size.equalTo(18)
            make.centerY.equalTo(likeCountLabel)
            make.trailing.equalTo(likeCountLabel.snp.leading)
        }
    }
}

extension OtherUserCommentSectionCell: Inputable {
    struct Input {
        var imagePath: String?
        var likeCount: Int64
        var title: String?
        var comment: String?
        var date: String?
        var popUpID: Int64
    }
    
    func injection(with input: Input) {
        imageView.setPPImage(path: input.imagePath)
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 11))
        contentLabel.setLineHeightText(text: input.comment, font: .KorFont(style: .medium, size: 11))
        dateLabel.setLineHeightText(text: input.date, font: .KorFont(style: .regular, size: 11))
        likeCountLabel.setLineHeightText(text: "\(input.likeCount)", font: .KorFont(style: .regular, size: 11))
    }
}
