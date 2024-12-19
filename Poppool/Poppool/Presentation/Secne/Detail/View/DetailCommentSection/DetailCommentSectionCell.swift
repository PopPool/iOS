//
//  DetailCommentSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/19/24.
//

import UIKit

import SnapKit
import RxSwift

final class DetailCommentSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 16
        return view
    }()
    
    let profileView: DetailCommentProfileView = {
        let view = DetailCommentProfileView()
        return view
    }()
    
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 80, height: 80)
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private let contentLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 13)
        label.numberOfLines = 3
        return label
    }()
    
    let totalViewButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let buttonTitleLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 13, text: "코멘트 전체보기")
        label.textColor = .g600
        return label
    }()
    
    private let buttonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_right_black")
        return view
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let likeButtonTitleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13, text: "도움돼요")
        label.textColor = .g400
        return label
    }()
    
    private let likeButtonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_like_gray")
        return view
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .g100
        return view
    }()
    
    var disposeBag = DisposeBag()
    
    private var imagePathList: [String?] = []
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
private extension DetailCommentSectionCell {
    func setUpConstraints() {
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(DetailCommentImageCell.self, forCellWithReuseIdentifier: DetailCommentImageCell.identifiers)
        
        
        totalViewButton.addSubview(buttonTitleLabel)
        buttonTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(20).priority(.high)
        }
        totalViewButton.addSubview(buttonImageView)
        buttonImageView.snp.makeConstraints { make in
            make.size.equalTo(14).priority(.high)
            make.trailing.equalToSuperview()
            make.leading.equalTo(buttonTitleLabel.snp.trailing)
            make.centerY.equalToSuperview()
        }
        
        profileView.snp.makeConstraints { make in
            make.width.equalTo(contentView.bounds.width - 40).priority(.high)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.height.equalTo(80).priority(.high)
            make.width.equalTo(contentView.bounds.width).priority(.high)
        }
        contentLabel.snp.makeConstraints { make in
            make.width.equalTo(contentView.bounds.width - 40).priority(.high)
        }
        contentStackView.addArrangedSubview(profileView)
        contentStackView.addArrangedSubview(imageCollectionView)
        contentStackView.addArrangedSubview(contentLabel)
        contentStackView.addArrangedSubview(totalViewButton)
        
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        likeButton.addSubview(likeButtonTitleLabel)
        likeButtonTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(20).priority(.high)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        likeButton.addSubview(likeButtonImageView)
        likeButtonImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(likeButtonTitleLabel.snp.leading)
        }
        
        contentView.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1).priority(.high)
            make.bottom.equalToSuperview()
        }
    }
}

extension DetailCommentSectionCell: Inputable {
    struct Input {
        var nickName: String?
        var profileImagePath: String?
        var date: String?
        var comment: String?
        var imageList: [String?]
    }
    
    func injection(with input: Input) {
        let comment = input.comment ?? ""
        profileView.profileImageView.setPPImage(path: input.profileImagePath)
        profileView.nickNameLabel.setLineHeightText(text: input.nickName)
        profileView.dateLabel.setLineHeightText(text: input.date)
        contentLabel.setLineHeightText(text: input.comment)
        if comment.count > 78 {
            totalViewButton.isHidden = false
        } else {
            totalViewButton.isHidden = true
        }
        if input.imageList.isEmpty {
            imageCollectionView.isHidden = true
        } else {
            imageCollectionView.isHidden = false
            imagePathList = input.imageList
            imageCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension DetailCommentSectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePathList.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCommentImageCell.identifiers, for: indexPath) as? DetailCommentImageCell else {
            return UICollectionViewCell()
        }
        cell.injection(with: .init(imagePath: imagePathList[indexPath.row]))
        return cell
    }

}
