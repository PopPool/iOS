import UIKit

import DesignSystem

import RxSwift
import SnapKit
import Then

final class CommentDetailContentSectionCell: UICollectionViewCell {

    // MARK: - Components

    private let contentLabel = PPLabel(style: .KOm13).then {
        $0.numberOfLines = 0
    }

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
private extension CommentDetailContentSectionCell {
    func setUpConstraints() {
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CommentDetailContentSectionCell: Inputable {
    struct Input {
        var content: String?
    }

    func injection(with input: Input) {
        contentLabel.updateText(to: input.content)
    }
}
