import UIKit
import SnapKit
import RxSwift
import ReactorKit

final class StoreListCell: UICollectionViewCell {
    static let identifier = "StoreListCell"

    // MARK: - Components
    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .g100
        return iv
    }()

    let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_bookmark"), for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        return button
    }()

    private let categoryTagLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12, text: "")
        label.textColor = .blu500
        label.text = "#카테고리"
        return label
    }()

    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 14, text: "")
        label.textColor = .g900
        label.numberOfLines = 2
        return label
    }()

    private let locationLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12, text: "")
        label.textColor = .g600
        return label
    }()

    private let dateLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12, text: "")
        label.textColor = .g600
        return label
    }()

    var disposeBag = DisposeBag()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
        configureUI()
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
private extension StoreListCell {
    func configureUI() {
        backgroundColor = .white
    }

    func setUpConstraints() {
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.width - 48) / 2)
            make.height.equalTo(thumbnailImageView.snp.width)
        }

        thumbnailImageView.addSubview(bookmarkButton)
        bookmarkButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.size.equalTo(24)
        }

        let labelStack = UIStackView(arrangedSubviews: [
            categoryTagLabel,
            titleLabel,
            locationLabel,
            dateLabel
        ])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        labelStack.alignment = .leading

        contentView.addSubview(labelStack)
        labelStack.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

// MARK: - Inputable
extension StoreListCell: Inputable {
    struct Input {
        let thumbnailImage: UIImage?
        let category: String
        let title: String
        let location: String
        let date: String
        let isBookmarked: Bool
    }

    func injection(with input: Input) {
        thumbnailImageView.image = input.thumbnailImage ?? UIImage(named: "default_thumbnail")
        categoryTagLabel.text = "#\(input.category)"
        titleLabel.text = input.title
        locationLabel.text = input.location
        dateLabel.text = input.date

        let bookmarkImage = input.isBookmarked ? "icon_bookmark_fill" : "icon_bookmark"
        bookmarkButton.setImage(UIImage(named: bookmarkImage), for: .normal)
    }
}
