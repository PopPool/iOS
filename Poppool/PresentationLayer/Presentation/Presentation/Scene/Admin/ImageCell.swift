import UIKit

import DesignSystem

import SnapKit

final class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"

    // UI
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }

    private let mainCheckButton = UIButton(type: .system).then {
        $0.setTitle("대표", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 4
    }

    private let deleteButton = UIButton(type: .system).then {
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
    }

    // 외부에서 주입받을 콜백
    var onMainCheckToggled: (() -> Void)?
    var onDeleteTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(mainCheckButton)
        contentView.addSubview(deleteButton)

        thumbnailImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(thumbnailImageView.snp.width)  // 정사각형
        }

        mainCheckButton.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(4)
            make.left.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(24)
        }

        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(4)
            make.right.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(24)
        }
    }

    private func setupActions() {
        mainCheckButton.addTarget(self, action: #selector(didTapMainCheck), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
    }

    @objc private func didTapMainCheck() {
        onMainCheckToggled?()
    }

    @objc private func didTapDelete() {
        onDeleteTapped?()
    }

    func configure(with item: ExtendedImage) {
        thumbnailImageView.image = item.image
        mainCheckButton.backgroundColor = item.isMain ? .systemRed : .gray
    }
}
