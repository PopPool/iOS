import UIKit
import SnapKit
import Kingfisher

final class PopupCardCell: UICollectionViewCell {
    static let identifier = "PopupCardCell"

    // MARK: - Components
    private let imageView = UIImageView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let dateLabel = UILabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupLayout() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(dateLabel)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(97)
        }

        categoryLabel.font = .systemFont(ofSize: 11, weight: .bold)
        categoryLabel.textColor = .systemBlue
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }

        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }

        addressLabel.font = .systemFont(ofSize: 12, weight: .regular)
        addressLabel.textColor = .g400
        addressLabel.numberOfLines = 2
        addressLabel.lineBreakMode = .byTruncatingTail

        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }

        dateLabel.font = .systemFont(ofSize: 12, weight: .light)
        dateLabel.textColor = .g400
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualTo(imageView)  // 이미지뷰 높이에 맞춤
        }
    }


    private func configureUI() {
        contentView.backgroundColor = UIColor.white
        categoryLabel.textColor = .systemBlue
        imageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }

    // MARK: - Configuration
    func configure(with store: MapPopUpStore) {
        titleLabel.text = store.name
        categoryLabel.text = "#\(store.category)"
        addressLabel.text = store.address

        // Date label formatting
        let startDate = store.startDate.split(separator: "T").first ?? ""
        let endDate = store.endDate.split(separator: "T").first ?? ""
        dateLabel.text = "\(startDate) ~ \(endDate)"

        if let imageUrl = store.mainImageUrl {
            imageView.setPPImage(path: imageUrl)
        } else {
            imageView.image = UIImage(named: "placeholderImage")
        }
    }
}
