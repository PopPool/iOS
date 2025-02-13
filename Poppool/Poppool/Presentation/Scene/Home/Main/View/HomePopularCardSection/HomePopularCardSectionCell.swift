//
//  HomePopularCardSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/30/24.
//

import UIKit

import SnapKit
import RxSwift
import Kingfisher

final class HomePopularCardSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    private var backGroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let blurView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 232, height: 332)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.init(hexCode: "#FFFFFF", alpha: 0).cgColor,
            UIColor.init(hexCode: "#141414", alpha: 0.4).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)  // 시작점
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)    // 끝점
        gradientLayer.bounds = view.bounds
        gradientLayer.position = view.center
        view.layer.addSublayer(gradientLayer)
        return view
    }()
    
    private let dateLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 16)
        label.textColor = .w100
        return label
    }()
    
    private let categoryLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 16)
        label.textColor = .w100
        return label
    }()
    
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 16)
        label.numberOfLines = 2
        label.textColor = .w100
        return label
    }()
    
    let disposeBag = DisposeBag()
    
    private let imageService = PreSignedService()
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
private extension HomePopularCardSectionCell {
    func setUpConstraints() {
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        
        contentView.addSubview(backGroundImageView)
        backGroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backGroundImageView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.top).offset(-16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(categoryLabel.snp.top).offset(-6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        

    }
}

extension HomePopularCardSectionCell: Inputable {
    struct Input {
        var imagePath: String?
        var endDate: String?
        var category: String?
        var title: String?
        var id: Int64
    }
    
    func injection(with input: Input) {
        let date = "#\(input.endDate.toDate().toPPDateMonthString())까지 열리는"
        dateLabel.setLineHeightText(text: date, font: .KorFont(style: .regular, size: 16))
        let category = "#\(input.category ?? "")"
        categoryLabel.setLineHeightText(text: category, font: .KorFont(style: .regular, size: 16))
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .regular, size: 16))
        backGroundImageView.setPPImage(path: input.imagePath)
    }
}
