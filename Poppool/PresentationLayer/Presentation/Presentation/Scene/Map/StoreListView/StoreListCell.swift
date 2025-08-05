import UIKit

import DesignSystem
import Infrastructure

import ReactorKit
import RxSwift
import SnapKit
import Then

final class StoreListCell: UICollectionViewCell {
    static let identifier = "StoreListCell"

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private enum Constant {
        static let imageHeight: CGFloat = 140
        static let bookmarkSize: CGFloat = 24
        static let bookmarkInset: CGFloat = 8
        static let categoryTopOffset: CGFloat = 12
        static let categoryHeight: CGFloat = 15
        static let titleTopOffset: CGFloat = 4
        static let addressHeight: CGFloat = 17
        static let dateHeight: CGFloat = 15
        static let cornerRadius: CGFloat = 12
        static let cellCornerRadius: CGFloat = 4
    }

    // MARK: - Components
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Constant.cornerRadius
        $0.backgroundColor = .g100
    }

    let bookmarkButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_bookmark"), for: .normal)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = Constant.cornerRadius
    }

    private let categoryTagLabel = PPLabel(style: .bold, fontSize: 11).then {
        $0.textColor = .blu500
        $0.setLineHeightText(text: "category", font: .korFont(style: .bold, size: 11))
    }

    private let titleLabel = PPLabel(style: .bold, fontSize: 14).then {
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .g900
        $0.setLineHeightText(text: "title", font: .korFont(style: .bold, size: 14))
    }

    private let locationLabel = PPLabel(style: .medium, fontSize: 11).then {
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .g400
        $0.setLineHeightText(text: "location", font: .korFont(style: .medium, size: 11))
    }

    private let dateLabel = PPLabel(style: .medium, fontSize: 11).then {
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .g400
        $0.setLineHeightText(text: "date", font: .korFont(style: .medium, size: 11))
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - SetUp
private extension StoreListCell {
    func addViews() {
        [thumbnailImageView, categoryTagLabel, titleLabel, locationLabel, dateLabel, bookmarkButton].forEach {
            self.contentView.addSubview($0)
        }
    }

    func setupConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.width.equalTo(self.contentView.bounds.width)
            make.height.equalTo(Constant.imageHeight)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        bookmarkButton.snp.makeConstraints { make in
            make.size.equalTo(Constant.bookmarkSize)
            make.top.trailing.equalToSuperview().inset(Constant.bookmarkInset)
        }

        categoryTagLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(self.thumbnailImageView.snp.bottom).offset(Constant.categoryTopOffset)
            make.height.equalTo(Constant.categoryHeight)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.categoryTagLabel.snp.bottom).offset(Constant.titleTopOffset)
            make.leading.trailing.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(Constant.dateHeight).priority(.high)
            make.bottom.equalToSuperview()
        }

        locationLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.dateLabel.snp.top)
            make.height.equalTo(Constant.addressHeight).priority(.high)
        }
    }

    func configureUI() {
        self.contentView.layer.cornerRadius = Constant.cellCornerRadius
        self.contentView.clipsToBounds = true

        self.thumbnailImageView.layer.cornerRadius = Constant.cornerRadius
        self.thumbnailImageView.clipsToBounds = true
    }
}

extension StoreListCell: Inputable {
    struct Input {
        let thumbnailURL: String
        let category: String
        let title: String
        let location: String
        let date: String
        let isBookmarked: Bool
    }

    func injection(with input: Input) {
        self.thumbnailImageView.setPPImage(path: input.thumbnailURL)
        self.categoryTagLabel.updateText(to: "#\(input.category)")
        self.titleLabel.updateText(to: input.title)
        self.locationLabel.updateText(to: input.location)
        self.dateLabel.updateText(to: input.date)

        let bookmarkImage = input.isBookmarked ? "icon_bookmark_fill" : "icon_bookmark"
        self.bookmarkButton.setImage(UIImage(named: bookmarkImage), for: .normal)
    }
}