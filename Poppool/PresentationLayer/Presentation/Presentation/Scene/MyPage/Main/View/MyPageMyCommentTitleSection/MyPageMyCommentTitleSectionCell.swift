import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class MyPageMyCommentTitleSectionCell: UICollectionViewCell {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 16)
    }()

    let button: UIButton = {
        return UIButton()
    }()

    var disposeBag = DisposeBag()
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
private extension MyPageMyCommentTitleSectionCell {
    func setUpConstraints() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
        }

        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
    }
}

extension MyPageMyCommentTitleSectionCell: Inputable {
    struct Input {
        var title: String?
        var buttonTitle: String?
    }

    func injection(with input: Input) {
        titleLabel.setLineHeightText(text: input.title, font: .korFont(style: .bold, size: 16))

        if input.buttonTitle != nil {
            let buttonTitle = NSAttributedString(
                string: input.buttonTitle ?? "",
                attributes: [
                    .font: UIFont.korFont(style: .regular, size: 13),
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.g600
                ]
            )
            button.setAttributedTitle(buttonTitle, for: .normal)
            button.isHidden = false
        } else {
            button.isHidden = true
        }
    }
}
