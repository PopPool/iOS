//
//  ImageBannerChildSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/29/24.
//

import UIKit

import RxSwift
import SnapKit

final class ImageBannerChildSectionCell: UICollectionViewCell {

    // MARK: - Components

    let disposeBag = DisposeBag()

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
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
private extension ImageBannerChildSectionCell {
    func setUpConstraints() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ImageBannerChildSectionCell: Inputable {
    struct Input {
        var imagePath: String?
        var id: Int64
    }

    func injection(with input: Input) {
        imageView.setPPImage(path: input.imagePath)
    }
}
