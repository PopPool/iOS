import UIKit
import SnapKit

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
//        contentView.layer.borderWidth = 1
//        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(dateLabel)

        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(97)
        }

        categoryLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        categoryLabel.textColor = .systemBlue
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel.numberOfLines = 2
//        titleLabel.textColor = g1000
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        // Address Label
        addressLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addressLabel.textColor = .g400
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        // Date Label
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        dateLabel.textColor = .g400
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }

    private func configureUI() {
        // 배경색 설정
        contentView.backgroundColor = UIColor.white

        // 카테고리 강조 색상
        categoryLabel.textColor = .systemBlue

        // Placeholder 배경 설정
        imageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }

    // MARK: - Configuration
    func configure(with store: MapPopUpStore) {
        titleLabel.text = store.name
        categoryLabel.text = "#\(store.category)"
        addressLabel.text = store.address
        dateLabel.text = "\(store.startDate) ~ \(store.endDate)"

        imageView.image = UIImage(named: "placeholderImage") // 실제 이미지 로직에 맞게 수정 예정
    }
}
