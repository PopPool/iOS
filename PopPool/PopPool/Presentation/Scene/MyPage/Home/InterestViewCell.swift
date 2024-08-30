//
//  InterestViewCell.swift
//  PopPool
//
//  Created by Porori on 8/18/24.
//

import UIKit
import SnapKit
import RxSwift

final class InterestViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let containerView = UIView()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descriptionLabel)
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "테스트"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "테스팅테스팅테스팅"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        setUpConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(title: String, category: String, image: UIImage?) {
        titleLabel.text = title
        descriptionLabel.text = category
        imageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.text = nil
        titleLabel.text = nil
        imageView.image = UIImage(systemName: "photo")
    }
    
    private func setUp() {
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        titleLabel.textColor = .w100
    }
    
    private func setUpConstraint() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(332)
        }
        imageView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension InterestViewCell: Cellable {
    
    struct Input {
        var image: URL?
        var category: String?
        var title: String?
        var location: String?
        var date: String?
    }
    
    struct Output {
        
    }
    
    func injectionWith(input: Input) {
        imageView.kf.indicatorType = .activity
        if let popularPopUp = input.image {
            imageView.kf.setImage(with: popularPopUp)
            descriptionLabel.text = input.title
            titleLabel.text = "#\(input.date)까지 열리는\n#\(input.category) #\(input.location)"
        } else {
            imageView.image = UIImage(named: "defaultLogo") // 배너 기본 이미지 설정
        }
    }
    
    func getOutput() -> Output {
        return Output()
    }
}
