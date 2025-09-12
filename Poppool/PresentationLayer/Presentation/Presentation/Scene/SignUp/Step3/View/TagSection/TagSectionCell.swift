import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class TagSectionCell: UICollectionViewCell {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        return PPLabel(style: .KOm13)
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
private extension TagSectionCell {
    func setUpConstraints() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 18
        contentView.layer.borderColor = UIColor.g200.cgColor

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14).priority(.high)
            make.center.equalToSuperview()
        }
    }
}

extension TagSectionCell: Inputable {
    struct Input {
        var title: String?
        var isSelected: Bool
        var id: Int?
    }

    func injection(with input: Input) {
        titleLabel.updateText(to: input.title)
        if input.isSelected {
            contentView.backgroundColor = .blu500
            contentView.layer.borderWidth = 0
            titleLabel.updateTextColor(to: .w100)
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.borderWidth = 1
            titleLabel.updateTextColor(to: .g400)
        }
    }
}
