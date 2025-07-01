import UIKit

import RxSwift
import SnapKit

public final class PPTagCollectionViewCell: UICollectionViewCell {

    // MARK: - Components

    public var disposeBag = DisposeBag()

    public let titleLabel = PPLabel(style: .medium, fontSize: 11)

    public let cancelButton = UIButton()

    private let contentStackView = UIStackView().then {
        $0.alignment = .center
        $0.spacing = 2
    }

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        configureCell(
            title: nil,
            id: nil,
            isSelected: false,
            isCancelable: false,
            fontSize: 11,
            cornerRadius: 15.5
        )

        disposeBag = DisposeBag()
    }
}

// MARK: - SetUp
private extension PPTagCollectionViewCell {
    func addViews() {
        [contentStackView].forEach {
            self.contentView.addSubview($0)
        }

        [titleLabel, cancelButton].forEach {
            contentStackView.addArrangedSubview($0)
        }
    }

    func setupConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(8)
        }

        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }

        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }

    func configureUI() {
        contentView.layer.cornerRadius = 15.5
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
    }
}

extension PPTagCollectionViewCell {
    public func configureCell(title: String? = nil, id: Int?, isSelected: Bool = false, isCancelable: Bool = true, fontSize: CGFloat = 11, cornerRadius: CGFloat = 15.5) {
        let xmarkImage = isSelected ? UIImage(named: "icon_xmark_white") : UIImage(named: "icon_xmark_gray")
        cancelButton.setImage(xmarkImage, for: .normal)
        if isSelected {
            contentView.backgroundColor = .blu500
            titleLabel.setLineHeightText(text: title, font: .korFont(style: .medium, size: fontSize), lineHeight: 1.15)
            titleLabel.textColor = .w100
            contentView.layer.borderColor = UIColor.blu500.cgColor
        } else {
            contentView.backgroundColor = .clear
            titleLabel.setLineHeightText(text: title, font: .korFont(style: .medium, size: fontSize), lineHeight: 1.15)
            titleLabel.textColor = .g400
            contentView.layer.borderColor = UIColor.g200.cgColor
        }
        cancelButton.isHidden = !isCancelable
        contentView.layer.cornerRadius = cornerRadius

        if isCancelable {
            contentStackView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().inset(8)
            }
        } else {
            contentStackView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().inset(12)
            }
        }
    }
}
