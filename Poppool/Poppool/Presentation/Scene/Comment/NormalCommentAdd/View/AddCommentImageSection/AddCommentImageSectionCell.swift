//
//  AddCommentImageSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/14/24.
//

import UIKit

import RxSwift
import SnapKit

final class AddCommentImageSectionCell: UICollectionViewCell {

    // MARK: - Components

    var disposeBag = DisposeBag()

    private let imageView: UIImageView = {
        return UIImageView()
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .w100
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()

    private let xmarkImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_xmark")
        return view
    }()

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
private extension AddCommentImageSectionCell {
    func setUpConstraints() {
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        contentView.layer.borderColor = UIColor.blu400.cgColor

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.top.trailing.equalToSuperview().inset(6)
        }

        deleteButton.addSubview(xmarkImageView)
        xmarkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(12)
        }
    }
}

extension AddCommentImageSectionCell: Inputable {
    struct Input {
        var image: UIImage?
        var isFirstCell: Bool = false
        var isEditCase: Bool = false
        var imageURL: String?
        var imageID: Int64?
    }

    func injection(with input: Input) {

        if input.isFirstCell {
            imageView.image = UIImage(named: "icon_camera_blue")
            contentView.layer.borderWidth = 1
            deleteButton.isHidden = true
        } else {
            if input.isEditCase {
                contentView.layer.borderWidth = 0
                imageView.setPPImage(path: input.imageURL)
            } else {
                contentView.layer.borderWidth = 0
                imageView.image = input.image
            }
            deleteButton.isHidden = false
        }
    }
}
