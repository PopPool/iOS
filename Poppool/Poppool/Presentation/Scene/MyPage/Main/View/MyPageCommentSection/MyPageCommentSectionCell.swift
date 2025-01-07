//
//  MyPageCommentSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/2/25.
//

import UIKit

import SnapKit
import RxSwift

final class MyPageCommentSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    private let firstBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .g100
        view.layer.cornerRadius = 34
        return view
    }()
    
    private let imageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .w100
        view.layer.cornerRadius = 31
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 28
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 11)
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
private extension MyPageCommentSectionCell {
    func setUpConstraints() {
        contentView.addSubview(firstBackgroundView)
        firstBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(68)
        }
        
        firstBackgroundView.addSubview(imageBackgroundView)
        imageBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(62)
            make.center.equalToSuperview()
        }
        
        imageBackgroundView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(56)
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension MyPageCommentSectionCell: Inputable {
    struct Input {
        var popUpImagePath: String?
        var title: String?
        var popUpID: Int64
    }
    
    func injection(with input: Input) {
        imageView.setPPImage(path: input.popUpImagePath)
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .regular, size: 11))
        titleLabel.textAlignment = .center
    }
}
