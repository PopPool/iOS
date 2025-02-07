//
//  MyCommentedPopUpGridSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 2/6/25.
//

import UIKit

import SnapKit
import RxSwift

final class MyCommentedPopUpGridSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    private let contentImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blu500
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .g400
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
private extension MyCommentedPopUpGridSectionCell {
    func setUpConstraints() {
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .w100
        contentView.layer.shadowColor = UIColor(red: 0.008, green: 0.137, blue: 0.392, alpha: 0.08).cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        contentView.addSubview(contentImageView)
        contentImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(contentView.bounds.width)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}

extension MyCommentedPopUpGridSectionCell: Inputable {
    struct Input {
        var popUpID: Int64
        var imageURL: String?
        var title: String?
        var content: String?
        var startDate: String?
        var endDate: String?
    }
    
    func injection(with input: Input) {
        contentImageView.setPPImage(path: input.imageURL)
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 11))
        contentLabel.setLineHeightText(text: input.content, font: .KorFont(style: .medium, size: 11))
        contentLabel.numberOfLines = 2
        dateLabel.setLineHeightText(text: "\(input.startDate ?? "") ~ \(input.endDate ?? "")", font: .EngFont(style: .regular, size: 11))
    }
}
