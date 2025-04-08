import UIKit

import RxSwift
import SnapKit

final class HomeCardSectionCell: UICollectionViewCell {

    // MARK: - Components

    var disposeBag = DisposeBag()

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let categoryLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 11)
        label.textColor = .blu500
        return label
    }()

    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 14)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let addressLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 11)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .g400
        return label
    }()

    private let dateLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 11)
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .g400
        return label
    }()

    let bookmarkButton: UIButton = {
        return UIButton()
    }()

    private let rankLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .w10
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.isHidden = true
        label.textColor = .w100
        return label
    }()

    private let imageService = PreSignedService()
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
private extension HomeCardSectionCell {
    func setUpConstraints() {
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(contentView.bounds.width)
            make.height.equalTo(140)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true

        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.height.equalTo(15)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }

        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(15).priority(.high)
            make.bottom.equalToSuperview()
        }

        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(dateLabel.snp.top)
            make.height.equalTo(17).priority(.high)
        }

        contentView.addSubview(bookmarkButton)
        bookmarkButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.top.trailing.equalToSuperview().inset(8)
        }

        imageView.addSubview(rankLabel)
        rankLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(37)
            make.leading.bottom.equalToSuperview().inset(12)
        }
    }
}

extension HomeCardSectionCell: Inputable {
    struct Input {
        var imagePath: String?
        var id: Int64
        var category: String?
        var title: String?
        var address: String?
        var startDate: String?
        var endDate: String?
        var isBookmark: Bool
        var isLogin: Bool
        var isPopular: Bool = false
        var row: Int?
    }

    func injection(with input: Input) {
        categoryLabel.setLineHeightText(text: "#" + (input.category ?? ""), font: .korFont(style: .bold, size: 11))
        titleLabel.setLineHeightText(text: input.title, font: .korFont(style: .bold, size: 14))
        addressLabel.setLineHeightText(text: input.address, font: .korFont(style: .medium, size: 11))
        let date = input.startDate.toDate().toPPDateString() + " ~ " + input.endDate.toDate().toPPDateString()
        dateLabel.setLineHeightText(text: date, font: .korFont(style: .medium, size: 11))
        let bookmarkImage = input.isBookmark ? UIImage(named: "icon_bookmark_fill") : UIImage(named: "icon_bookmark")
        bookmarkButton.setImage(bookmarkImage, for: .normal)
        imageView.setPPImage(path: input.imagePath)
        bookmarkButton.isHidden = !input.isLogin

        rankLabel.isHidden = !input.isPopular
        let rank = input.row ?? 0
        rankLabel.setLineHeightText(text: "\(rank + 1)위", font: .korFont(style: .medium, size: 11), lineHeight: 1)
        rankLabel.textAlignment = .center
        if rank > 2 {
            rankLabel.isHidden = true
        }
    }
}
