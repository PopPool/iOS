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
        view.clipsToBounds = true
        return view
    }()
    
    private let imageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .w100
        view.layer.cornerRadius = 31
        return view
    }()
    
    private let gradientView: AnimatedGradientView = {
        let view = AnimatedGradientView()
        view.isHidden = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 28
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
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
        
        firstBackgroundView.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        var isFirstCell: Bool = false
    }
    
    func injection(with input: Input) {
        imageView.setPPImage(path: input.popUpImagePath)
        titleLabel.setLineHeightText(text: input.title, font: .KorFont(style: .regular, size: 11))
        titleLabel.textAlignment = .center
        
        if input.isFirstCell {
            gradientView.isHidden = false
        } else {
            gradientView.isHidden = true
        }
    }
}

class AnimatedGradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        // 초기 그라디언트 색상 설정
        gradientLayer.colors = [
            UIColor.init(hexCode: "#1570FC").cgColor,
            UIColor.init(hexCode: "#00E6BD").cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
        
        animateGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds // 레이아웃 변경 시 반영
    }
    
    private func animateGradient() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer.colors
        animation.toValue = [
            UIColor.init(hexCode: "#1570FC").cgColor,
            UIColor.init(hexCode: "#00E6BD").cgColor
        ]
        animation.duration = 1 // 색이 부드럽게 바뀌는 시간
        animation.autoreverses = true // 원래 색으로 돌아가게 함
        animation.repeatCount = .infinity // 무한 반복
        
        gradientLayer.add(animation, forKey: "colorChange")
    }
}
