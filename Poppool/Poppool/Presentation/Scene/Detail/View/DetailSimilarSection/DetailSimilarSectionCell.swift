//
//  DetailSimilarSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/19/24.
//

import UIKit

import SnapKit
import RxSwift

final class DetailSimilarSectionCell: UICollectionViewCell {
    
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
        label.textColor = .g400
        return label
    }()
    
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 12)
        return label
    }()
    
    let bookMarkButton: UIButton = {
        let button = UIButton()
        return button
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
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    private func addHolesToCell() {
        // 이미지뷰의 frame을 기준으로 위치 계산
        
        // 전체 영역 경로
        let fullPath = UIBezierPath(rect: bounds)
        let subPath = UIBezierPath(rect: bounds)
        
        // 왼쪽 아래와 오른쪽 아래 구멍을 뚫을 위치 설정 (이미지뷰의 frame 위치 고려)
        let leftHoleCenter = CGPoint(x: bounds.minX, y: 190)
        let rightHoleCenter = CGPoint(x: bounds.maxX, y: 190)
        
        // 구멍을 만드는 경로 생성 (반지름 6)
        let leftHolePath = UIBezierPath(arcCenter: leftHoleCenter, radius: 6, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
        let rightHolePath = UIBezierPath(arcCenter: rightHoleCenter, radius: 6, startAngle: .pi / 2, endAngle: -.pi / 2, clockwise: true)
        
        // 구멍 경로를 전체 경로에서 빼기
        fullPath.append(leftHolePath)
        fullPath.append(rightHolePath)
        fullPath.append(subPath)
        fullPath.usesEvenOddFillRule = true
        
        // 기존에 구멍을 뚫을 경로를 추가하는 레이어
        let holeLayer = CAShapeLayer()
        holeLayer.path = fullPath.cgPath
        holeLayer.fillRule = .evenOdd
        holeLayer.fillColor = UIColor.init(hexCode: "F2F3F7").cgColor
        
        // 구멍을 추가하는 서브 레이어로 삽입
        layer.addSublayer(holeLayer)
        
        // 그림자 설정
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
}

// MARK: - SetUp
private extension DetailSimilarSectionCell {
    func setUpConstraints() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(190)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(dateLabel.snp.bottom).offset(5.5)
        }
        
        contentView.addSubview(bookMarkButton)
        bookMarkButton.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.top.trailing.equalToSuperview().inset(12)
            
        }
    }
}

extension DetailSimilarSectionCell: Inputable {
    struct Input {
        var imagePath: String?
        var date: String?
        var title: String?
        var id: Int64
        var isBookMark: Bool?
    }
    
    func injection(with input: Input) {
        let date = input.date ?? ""
        imageView.setPPImage(path: input.imagePath)
        dateLabel.setLineHeightText(text: "~" + date, font: .EngFont(style: .regular, size: 11))
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 12))
        if let isBookMark = input.isBookMark {
            bookMarkButton.isHidden = false
            if isBookMark {
                bookMarkButton.setImage(UIImage(named: "icon_bookmark_fill"), for: .normal)
            } else {
                bookMarkButton.setImage(UIImage(named: "icon_bookmark"), for: .normal)
            }
        } else {
            bookMarkButton.isHidden = true
        }
    }
}
