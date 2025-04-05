//
//  BlockUserListSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/12/25.
//

import UIKit

import RxSwift
import SnapKit

final class BlockUserListSectionCell: UICollectionViewCell {

    // MARK: - Components

    var disposeBag = DisposeBag()

    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let nickNameLabel: UILabel = {
        return UILabel()
    }()

    let blockButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        return button
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
private extension BlockUserListSectionCell {
    func setUpConstraints() {
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.leading.centerY.equalToSuperview()
        }

        contentView.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
        }

        contentView.addSubview(blockButton)
        blockButton.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(32)

            make.centerY.trailing.equalToSuperview()
        }
    }
}

extension BlockUserListSectionCell: Inputable {
    struct Input {
        var profileImagePath: String?
        var nickName: String?
        var userID: String?
        var isBlocked: Bool
    }

    func injection(with input: Input) {
        profileImageView.setPPImage(path: input.profileImagePath)
        nickNameLabel.setLineHeightText(text: input.nickName, font: .korFont(style: .bold, size: 14))
        if input.isBlocked {
            blockButton.setTitle("차단완료", for: .normal)
            blockButton.titleLabel?.font = .korFont(style: .medium, size: 13)
            blockButton.backgroundColor = .re600
            blockButton.setTitleColor(.w100, for: .normal)
            blockButton.layer.borderWidth = 0
        } else {
            blockButton.setTitle("차단해제", for: .normal)
            blockButton.titleLabel?.font = .korFont(style: .medium, size: 13)
            blockButton.backgroundColor = .w100
            blockButton.setTitleColor(.g300, for: .normal)
            blockButton.layer.borderWidth = 1
            blockButton.layer.borderColor = UIColor.g200.cgColor
        }
    }
}
