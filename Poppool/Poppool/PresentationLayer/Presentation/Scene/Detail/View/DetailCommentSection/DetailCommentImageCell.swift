//
//  DetailCommentImageCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/19/24.
//

import UIKit

import RxSwift
import SnapKit

final class DetailCommentImageCell: UICollectionViewCell {

    // MARK: - Components
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
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
}

// MARK: - SetUp
private extension DetailCommentImageCell {
    func setUpConstraints() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension DetailCommentImageCell: Inputable {
    struct Input {
        var imagePath: String?
    }

    func injection(with input: Input) {
        imageView.setPPImage(path: input.imagePath)
    }
}
