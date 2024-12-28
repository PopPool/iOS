//
//  InstaGuideChildSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import SnapKit
import RxSwift

final class InstaGuideChildSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    let disposeBag = DisposeBag()
    
    private let indexTrailgView: UIView = {
        let view = UIView()
        view.backgroundColor = .g900
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.font = .EngFont(style: .medium, size: 16)
        label.textColor = .w100
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
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
}

// MARK: - SetUp
private extension InstaGuideChildSectionCell {
    func setUpConstraints() {
        contentView.addSubview(indexTrailgView)
        indexTrailgView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(36)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(40)
            make.height.equalTo(33)
        }
        
        indexTrailgView.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(indexTrailgView.snp.bottom).offset(16)
        }
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(335)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.bottom.equalToSuperview()
        }
    }
}

extension InstaGuideChildSectionCell: Inputable {
    struct Input {
        var image: UIImage?
        var title: NSMutableAttributedString?
        var index: Int
    }
    
    func injection(with input: Input) {
        indexLabel.text = "#\(input.index + 1)"
        titleLabel.attributedText = input.title
        imageView.image = input.image
    }
}
