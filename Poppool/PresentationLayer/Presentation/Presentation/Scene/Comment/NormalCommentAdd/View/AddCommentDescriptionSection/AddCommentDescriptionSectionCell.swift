import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class AddCommentDescriptionSectionCell: UICollectionViewCell {

    // MARK: - Components

    let disposeBag = DisposeBag()

    private let descriptionLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.textColor = .g600
        label.numberOfLines = 0
        return label
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
private extension AddCommentDescriptionSectionCell {
    func setUpConstraints() {
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AddCommentDescriptionSectionCell: Inputable {
    struct Input {
        var description: String?
    }

    func injection(with input: Input) {
        descriptionLabel.setLineHeightText(text: input.description, font: .korFont(style: .regular, size: 13))
    }
}
