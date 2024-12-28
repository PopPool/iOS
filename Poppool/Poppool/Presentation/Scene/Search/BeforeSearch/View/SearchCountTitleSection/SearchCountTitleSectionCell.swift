//
//  SearchCountTitleSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/5/24.
//

import UIKit

import SnapKit
import RxSwift

final class SearchCountTitleSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    var disposeBag = DisposeBag()
    
    private let countLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.textColor = .g400
        return label
    }()
    
    private let sortedTitleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        return label
    }()
    
    private let downImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_dropdown")
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let sortedButton: UIButton = {
        let button = UIButton()
        return button
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
private extension SearchCountTitleSectionCell {
    func setUpConstraints() {
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(sortedButton)
        sortedButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        sortedButton.addSubview(sortedTitleLabel)
        sortedTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        sortedButton.addSubview(downImageView)
        downImageView.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.centerY.equalToSuperview()
            make.leading.equalTo(sortedTitleLabel.snp.trailing).offset(6)
            make.trailing.equalToSuperview()
        }
    }
}

extension SearchCountTitleSectionCell: Inputable {
    struct Input {
        var count: Int64
        var sortedTitle: String?
    }
    
    func injection(with input: Input) {
        sortedTitleLabel.text = input.sortedTitle
        countLabel.text = "총 \(input.count)개"
    }
}
