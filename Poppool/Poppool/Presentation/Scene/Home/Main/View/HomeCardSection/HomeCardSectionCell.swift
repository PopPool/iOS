//
//  HomeCardSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/30/24.
//

import UIKit

import SnapKit
import RxSwift
import Kingfisher

final class HomeCardSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    var disposeBag = DisposeBag()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private let categoryLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 11)
        label.textColor = .blu500
        return label
    }()
    
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 14)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let addressLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 11)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .g400
        return label
    }()
    
    private let dateLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 11)
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .g400
        return label
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let imageService = PreSignedService()
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
private extension HomeCardSectionCell {
    func setUpConstraints() {
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(158)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        
        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.height.equalTo(15)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview()
        }
        
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.height.equalTo(17).priority(.high)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(addressLabel.snp.bottom)
            make.height.equalTo(15).priority(.high)
            make.bottom.equalToSuperview()
        }
        
        contentView.addSubview(bookmarkButton)
        bookmarkButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.top.trailing.equalToSuperview().inset(8)
        }
    }
}

extension HomeCardSectionCell: Inputable {
    struct Input {
        var imagePath: String?
        var id: Int64
        var category: String?
        var title: String?
        var address: String?
        var startDate: String?
        var endDate: String?
        var isBookmark: Bool
        var isLogin: Bool
    }
    
    func injection(with input: Input) {
        categoryLabel.setLineHeightText(text: "#" + (input.category ?? ""), font: .KorFont(style: .bold, size: 11))
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 14))
        addressLabel.setLineHeightText(text: input.address, font: .KorFont(style: .medium, size: 11))
        let date = input.startDate.toDate().toPPDateString() + " ~ " + input.endDate.toDate().toPPDateString()
        dateLabel.setLineHeightText(text: date, font: .KorFont(style: .medium, size: 11))
        let bookmarkImage = input.isBookmark ? UIImage(named: "icon_bookmark_fill") : UIImage(named: "icon_bookmark")
        bookmarkButton.setImage(bookmarkImage, for: .normal)
        imageView.setPPImage(path: input.imagePath)
        bookmarkButton.isHidden = !input.isLogin
    }
}
