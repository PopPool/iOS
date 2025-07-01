import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class NoticeListSectionCell: UICollectionViewCell {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        return PPLabel(style: .medium, fontSize: 14)
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .g400
        return label
    }()

    private let arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_right_gray")
        return view
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
private extension NoticeListSectionCell {
    func setUpConstraints() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }

        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }

        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension NoticeListSectionCell: Inputable {
    struct Input {
        var title: String?
        var date: String?
        var noticeID: Int64
    }

    func injection(with input: Input) {
        titleLabel.setLineHeightText(text: input.title, font: .korFont(style: .medium, size: 14))
        dateLabel.setLineHeightText(text: input.date, font: .engFont(style: .regular, size: 12))
    }
}
