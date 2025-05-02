import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class DetailEmptyCommetSectionCell: UICollectionViewCell {

    // MARK: - Components

    private let noticeLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "아직 작성된 코멘트가 없어요\n가장 먼저 후기를 남겨주시겠어요?", lineHeight: 1.5)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .g400
        return label
    }()

    let commentButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(
            string: "첫번째 코멘트 남기기",
            attributes: [
                .font: UIFont.korFont(style: .regular, size: 13)!,  // 커스텀 폰트 적용
                .underlineStyle: NSUnderlineStyle.single.rawValue // 밑줄 스타일
            ]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
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
private extension DetailEmptyCommetSectionCell {
    func setUpConstraints() {
        contentView.addSubview(noticeLabel)
        noticeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(80)
            make.centerX.equalToSuperview()
        }

        contentView.addSubview(commentButton)
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(noticeLabel.snp.bottom).offset(26)
            make.centerX.equalToSuperview()
        }
    }
}

extension DetailEmptyCommetSectionCell: Inputable {
    struct Input {

    }

    func injection(with input: Input) {

    }
}
