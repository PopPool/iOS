import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class AddCommentTitleSectionCell: UICollectionViewCell {

    // MARK: - Components

    let disposeBag = DisposeBag()

    private let titleLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 16)
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
private extension AddCommentTitleSectionCell {
    func setUpConstraints() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AddCommentTitleSectionCell: Inputable {
    struct Input {
        var title: String?
    }

    func injection(with input: Input) {
        titleLabel.setLineHeightText(text: input.title, font: .korFont(style: .bold, size: 16))
    }
}
