//
//  PopUpCardSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class PopUpCardSectionCell: UICollectionViewCell {

    // MARK: - Components
    let imageView: UIImageView = {
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
        label.numberOfLines = 2
        return label
    }()

    private let addressLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 12)
        label.textColor = .g400
        return label
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
        addHolesToCell()
        setUpConstraints()
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
        let leftHoleCenter = CGPoint(x: contentView.bounds.minX, y: 423)
        let rightHoleCenter = CGPoint(x: contentView.bounds.maxX, y: 423)

        // 구멍을 만드는 경로 생성 (반지름 6)
        let leftHolePath = UIBezierPath(arcCenter: leftHoleCenter, radius: 12, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
        let rightHolePath = UIBezierPath(arcCenter: rightHoleCenter, radius: 12, startAngle: .pi / 2, endAngle: -.pi / 2, clockwise: true)

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
private extension PopUpCardSectionCell {
    func setUpConstraints() {

        contentView.addSubview(trailingView)
        trailingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        trailingView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(423)
        }

        trailingView.addSubview(bookMarkButton)
        bookMarkButton.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.top.trailing.equalToSuperview().inset(20)
        }

        trailingView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }

        trailingView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        trailingView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
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
        var isBookMark: Bool
    }

    func injection(with input: Input) {
        let date = input.date ?? ""
        imageView.setPPImage(path: input.imagePath)
        dateLabel.setLineHeightText(text: date, font: .EngFont(style: .regular, size: 13))
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .bold, size: 16))
        titleLabel.textAlignment = .center
        addressLabel.setLineHeightText(text: input.address, font: .KorFont(style: .regular, size: 14))
        addressLabel.textAlignment = .center

        if input.isBookMark {
            bookMarkButton.setImage(UIImage(named: "icon_bookmark_fill"), for: .normal)
        } else {
            bookMarkButton.setImage(UIImage(named: "icon_bookmark"), for: .normal)
        }
    }
}
