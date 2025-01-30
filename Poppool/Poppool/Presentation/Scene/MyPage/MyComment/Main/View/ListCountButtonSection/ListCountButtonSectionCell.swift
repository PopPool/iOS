//
//  ListCountButtonSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import UIKit

import SnapKit
import RxSwift

final class ListCountButtonSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    
    private let countLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.textColor = .g400
        return label
    }()
    
    private let dropDownImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_dropdown")
        return view
    }()
    
    private let buttonTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let dropdownButton: UIButton = {
        let button = UIButton()
        return button
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
private extension ListCountButtonSectionCell {
    func setUpConstraints() {
        self.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        dropdownButton.addSubview(dropDownImageView)
        dropDownImageView.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.top.trailing.bottom.equalToSuperview()
        }
        
        dropdownButton.addSubview(buttonTitleLabel)
        buttonTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(dropDownImageView.snp.leading).offset(-6)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(dropdownButton)
        dropdownButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension ListCountButtonSectionCell: Inputable {
    struct Input {
        var count: Int64
        var buttonTitle: String?
    }
    
    func injection(with input: Input) {
        countLabel.setLineHeightText(text: "총 \(input.count)개", font: .KorFont(style: .regular, size: 13))
        buttonTitleLabel.setLineHeightText(text: input.buttonTitle, font: .KorFont(style: .regular, size: 13))
    }
}
