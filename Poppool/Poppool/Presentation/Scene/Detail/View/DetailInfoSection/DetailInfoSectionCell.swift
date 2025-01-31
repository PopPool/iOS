//
//  DetailInfoSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/18/24.
//

import UIKit

import SnapKit
import RxSwift

final class DetailInfoSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    
    private let dateTitleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 13, text: "기간")
        return label
    }()
    
    private let dateLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 14)
        return label
    }()
    
    private let timeTitleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 13, text: "시간")
        return label
    }()
    
    private let timeLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 14)
        return label
    }()
    
    private let addressTitleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 13, text: "주소")
        return label
    }()
    
    private let addressLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    let copyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_copy_gray"), for: .normal)
        return button
    }()
    
    let mapButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    let mapButtonTitle: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13, text: "찾아가는 길")
        label.textColor = .blu500
        return label
    }()
    
    let mapButtonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_arrow_right_blue")
        return view
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
private extension DetailInfoSectionCell {
    func setUpConstraints() {
        contentView.addSubview(dateTitleLabel)
        dateTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateTitleLabel)
            make.leading.equalTo(dateTitleLabel.snp.trailing).offset(12)
        }
        
        contentView.addSubview(timeTitleLabel)
        timeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(11)
            make.leading.equalToSuperview()
        }
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(timeTitleLabel)
            make.leading.equalTo(timeTitleLabel.snp.trailing).offset(12)
        }
        
        contentView.addSubview(addressTitleLabel)
        addressTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(timeTitleLabel.snp.bottom).offset(11)
            make.leading.equalToSuperview()
        }
        
        mapButton.addSubview(mapButtonTitle)
        mapButtonTitle.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        mapButton.addSubview(mapButtonImageView)
        mapButtonImageView.snp.makeConstraints { make in
            make.leading.equalTo(mapButtonTitle.snp.trailing)
            make.size.equalTo(14)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview().offset(0.5)
        }
        
        contentView.addSubview(mapButton)
        mapButton.snp.makeConstraints { make in
            make.centerY.equalTo(addressTitleLabel)
            make.trailing.equalToSuperview()
        }
        
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(addressTitleLabel).offset(-2)
            make.leading.equalTo(addressTitleLabel.snp.trailing).offset(12)
            make.width.lessThanOrEqualTo(188)
            make.bottom.equalToSuperview()
        }
        
        contentView.addSubview(copyButton)
        copyButton.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.top.equalTo(addressLabel).offset(1)
            make.leading.equalTo(addressLabel.snp.trailing).offset(2)
        }
        

    }
}

extension DetailInfoSectionCell: Inputable {
    struct Input {
        var startDate: String?
        var endDate: String?
        var startTime: String?
        var endTime: String?
        var address: String?
    }
    
    func injection(with input: Input) {
        let startDate = input.startDate ?? "?"
        let endDate = input.endDate ?? "?"
        let startTime = input.startTime ?? "?"
        let endTime = input.endTime ?? "?"
        
        dateLabel.setLineHeightText(text: startDate + " ~ " + endDate, font: .KorFont(style: .regular, size: 14))
        timeLabel.setLineHeightText(text: startTime + " ~ " + endTime, font: .KorFont(style: .regular, size: 14))
        addressLabel.setLineHeightText(text: input.address, font: .KorFont(style: .regular, size: 13))
    }
}
    
