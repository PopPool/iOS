import UIKit

import Infrastructure

import RxSwift
import SnapKit

public final class PPPopupGridCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    public var disposeBag = DisposeBag()

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }

    private let categoryLabel = PPLabel(style: .bold, fontSize: 11).then {
        $0.textColor = .blu500
        $0.setLineHeightText(text: "category", font: .korFont(style: .bold, size: 11))
    }

    private let titleLabel = PPLabel(style: .bold, fontSize: 14).then {
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
        $0.setLineHeightText(text: "title", font: .korFont(style: .bold, size: 14))
    }

    private let addressLabel = PPLabel(style: .medium, fontSize: 11).then {
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .g400
        $0.setLineHeightText(text: "address", font: .korFont(style: .medium, size: 11))
    }

    private let dateLabel = PPLabel(style: .medium, fontSize: 11).then {
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .g400
        $0.setLineHeightText(text: "date", font: .korFont(style: .medium, size: 11))
    }

    public let bookmarkButton = UIButton()

    private let rankLabel = UILabel().then {
        $0.backgroundColor = .w10
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.textColor = .w100
        $0.textAlignment = .center
        $0.setLineHeightText(text: "rank", font: .korFont(style: .medium, size: 11), lineHeight: 1)
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
private extension PPPopupGridCollectionViewCell {
    func addViews() {
        [imageView, categoryLabel, titleLabel, dateLabel, addressLabel, bookmarkButton].forEach {
            self.contentView.addSubview($0)
        }

        [rankLabel].forEach {
            imageView.addSubview($0)
        }
    }

    func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.width.equalTo(contentView.bounds.width)
            make.height.equalTo(140)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        categoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.height.equalTo(15)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(15).priority(.high)
            make.bottom.equalToSuperview()
        }

        addressLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(dateLabel.snp.top)
            make.height.equalTo(17).priority(.high)
        }

        bookmarkButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.top.trailing.equalToSuperview().inset(8)
        }

        rankLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(37)
            make.leading.bottom.equalToSuperview().inset(12)
        }
    }

    func configureUI() {
        self.contentView.layer.cornerRadius = 4
        self.contentView.clipsToBounds = true

        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
    }
}

extension PPPopupGridCollectionViewCell {
    public func configureCell(imagePath: String?, id: Int64, category: String?, title: String?, address: String?, startDate: String?, endDate: String?, isBookmark: Bool, isLogin: Bool, isPopular: Bool = false, row: Int?) {

        categoryLabel.text = "#" + (category ?? "")
        titleLabel.text = title
        addressLabel.text = address

        let date = startDate.toDate().toPPDateString() + " ~ " + endDate.toDate().toPPDateString()
        dateLabel.text = date

        let bookmarkImage = isBookmark ? UIImage(named: "icon_bookmark_fill") : UIImage(named: "icon_bookmark")
        bookmarkButton.setImage(bookmarkImage, for: .normal)

        imageView.setPPImage(path: imagePath)

        bookmarkButton.isHidden = !isLogin
        rankLabel.isHidden = !isPopular

        if let rank = row {
            rankLabel.text = "\(rank)"
            rankLabel.isHidden = rank > 2
        }
    }
}
