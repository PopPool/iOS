import UIKit

import DesignSystem

import RxSwift
import SnapKit

public final class TagCollectionViewCell: UICollectionViewCell {

    // MARK: - Components

    var disposeBag = DisposeBag()

    private let titleLabel = PPLabel(style: .medium, fontSize: 11)

    let cancelButton = UIButton()

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
        disposeBag = DisposeBag()
    }
}

// MARK: - SetUp
private extension TagCollectionViewCell {
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

extension TagCollectionViewCell: Inputable {
    public struct Input: Hashable {
        var title: String?
        var id: Int? = nil
        var isSelected: Bool = false
        var isCancelable: Bool = true

        func selectionToggledItem() -> Input {
            let toggledSelection = !isSelected
            return Input(title: self.title, id: self.id, isSelected: toggledSelection, isCancelable: self.isCancelable)
        }
    }

    public func injection(with input: Input) {
        let xmarkImage = input.isSelected ? UIImage(named: "icon_xmark_white") : UIImage(named: "icon_xmark_gray")
        cancelButton.setImage(xmarkImage, for: .normal)
        if input.isSelected {
            contentView.backgroundColor = .blu500
            titleLabel.setLineHeightText(text: input.title, font: .korFont(style: .bold, size: 11), lineHeight: 1.15)
            titleLabel.textColor = .w100
            contentView.layer.borderColor = UIColor.blu500.cgColor
        } else {
            contentView.backgroundColor = .clear
            titleLabel.setLineHeightText(text: input.title, font: .korFont(style: .medium, size: 11), lineHeight: 1.15)
            titleLabel.textColor = .g400
            contentView.layer.borderColor = UIColor.g200.cgColor
        }
        cancelButton.isHidden = !input.isCancelable

        if input.isCancelable {
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
