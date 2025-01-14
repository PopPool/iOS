//
//  PopUpCardSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import UIKit

import SnapKit
import RxSwift

final class PopUpCardSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let dateLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 11)
        label.font = .EngFont(style: .regular, size: 11)
        label.textColor = .g1000
        return label
    }()
    
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 12)
        return label
    }()
    
    private let addressLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 12)
        label.textColor = .g400
        return label
    }()
    
    
    var disposeBag = DisposeBag()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .w100
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        setUpConstraints()
        addHolesToCell()

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addHolesToCell() {
        // 이미지뷰의 frame을 기준으로 위치 계산
        
        // 전체 영역 경로
        let fullPath = UIBezierPath(rect: bounds)
        let subPath = UIBezierPath(rect: bounds)
        
        // 왼쪽 아래와 오른쪽 아래 구멍을 뚫을 위치 설정 (이미지뷰의 frame 위치 고려)
        let leftHoleCenter = CGPoint(x: bounds.minX, y: 423)
        let rightHoleCenter = CGPoint(x: bounds.maxX, y: 423)
        
        // 구멍을 만드는 경로 생성 (반지름 6)
        let leftHolePath = UIBezierPath(arcCenter: leftHoleCenter, radius: 12, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
        let rightHolePath = UIBezierPath(arcCenter: rightHoleCenter, radius: 12, startAngle: .pi / 2, endAngle: -.pi / 2, clockwise: true)
        
        // 구멍 경로를 전체 경로에서 빼기
        fullPath.append(leftHolePath)
        fullPath.append(rightHolePath)
        fullPath.append(subPath)
        fullPath.usesEvenOddFillRule = true
        
        // 기존에 구멍을 뚫을 경로를 추가하는 레이어
        let holeLayer = CAShapeLayer()
        holeLayer.path = fullPath.cgPath
        holeLayer.fillRule = .evenOdd
        holeLayer.fillColor = UIColor.g50.cgColor
        
        // 구멍을 추가하는 서브 레이어로 삽입
        layer.addSublayer(holeLayer)
    }
}

// MARK: - SetUp
private extension PopUpCardSectionCell {
    func setUpConstraints() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(423)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
        }
        
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
        }
    }
}

extension PopUpCardSectionCell: Inputable {
    struct Input {
        var imagePath: String?
        var date: String?
        var title: String?
        var id: Int64
        var address: String?
    }
    
    func injection(with input: Input) {
        let date = input.date ?? ""
        imageView.setPPImage(path: input.imagePath)
        dateLabel.setLineHeightText(text: date, font: .EngFont(style: .regular, size: 13))
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 16))
        addressLabel.setLineHeightText(text: input.address, font: .KorFont(style: .regular, size: 14))
    }
}
