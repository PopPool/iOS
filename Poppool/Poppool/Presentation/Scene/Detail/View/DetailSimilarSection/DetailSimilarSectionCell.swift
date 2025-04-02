//
//  DetailSimilarSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/19/24.
//

import UIKit

import RxSwift
import SnapKit

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
        return PPLabel(style: .bold, fontSize: 12)
    }()

    let bookMarkButton: UIButton = {
        return UIButton()
    }()

    private let trailingView: UIView = UIView()

    var disposeBag = DisposeBag()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        trailingView.backgroundColor = .w100
        trailingView.clipsToBounds = true
        trailingView.layer.cornerRadius = 4
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
        // 전체 영역 경로
        let fullPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 4)

        // 왼쪽 아래와 오른쪽 아래 구멍을 뚫을 위치 설정 (이미지뷰의 frame 위치 고려)
        let leftHoleCenter = CGPoint(x: contentView.bounds.minX, y: 190)
        let rightHoleCenter = CGPoint(x: contentView.bounds.maxX, y: 190)

        // 구멍을 만드는 경로 생성 (반지름 6)
        let leftHolePath = UIBezierPath(arcCenter: leftHoleCenter, radius: 6, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
        let rightHolePath = UIBezierPath(arcCenter: rightHoleCenter, radius: 6, startAngle: .pi / 2, endAngle: -.pi / 2, clockwise: true)

        // 구멍 경로를 전체 경로에서 빼기
        fullPath.append(leftHolePath)
        fullPath.append(rightHolePath)
        fullPath.usesEvenOddFillRule = true

        // 기존에 구멍을 뚫을 경로를 추가하는 레이어
        let holeLayer = CAShapeLayer()
        holeLayer.path = fullPath.cgPath
        holeLayer.fillRule = .evenOdd
        holeLayer.fillColor = UIColor.black.cgColor
        trailingView.layer.mask = holeLayer

        // 그림자 Layer
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = fullPath.cgPath
        shadowLayer.fillRule = .evenOdd
        shadowLayer.shadowColor = UIColor(red: 0.008, green: 0.137, blue: 0.392, alpha: 0.08).cgColor
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 8
        shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
        shadowLayer.fillColor = UIColor.white.cgColor // 셀 배경과 동일하게 설
        contentView.layer.insertSublayer(shadowLayer, below: trailingView.layer)
    }
}

// MARK: - SetUp
private extension DetailSimilarSectionCell {
    func setUpConstraints() {
        contentView.addSubview(trailingView)
        trailingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        trailingView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(190)
        }

        trailingView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        trailingView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(dateLabel.snp.bottom).offset(5.5)
        }

        trailingView.addSubview(bookMarkButton)
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
