import UIKit
import SnapKit
import RxSwift
final class AdminStoreCell: UITableViewCell {
    private let disposeBag = DisposeBag()

    // MARK: - Identifier
    static let identifier = "AdminStoreCell"

    // MARK: - Components
    private let storeImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = .black
    }

    private let categoryLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .gray
    }

    private let statusChip = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .white
        $0.backgroundColor = .systemBlue
        $0.textAlignment = .center
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func setupLayout() {
        contentView.addSubview(storeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(statusChip)

        storeImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(storeImageView)
            make.leading.equalTo(storeImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
        }

        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
        }

        statusChip.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
            make.width.equalTo(60)
            make.height.equalTo(24)
        }
    }

    // MARK: - Configure
    func configure(with store: GetAdminPopUpStoreListResponseDTO.PopUpStore) {
        Logger.log(message: "셀 데이터 바인딩: \(store)", category: .debug)

        titleLabel.text = store.name
        categoryLabel.text = store.categoryName
        statusChip.text = "운영"

        // mainImageUrl에서 baseURL 부분 제거
        let imagePath = store.mainImageUrl.replacingOccurrences(of: Secrets.popPoolS3BaseURL.rawValue, with: "")
        Logger.log(message: "이미지 경로: \(imagePath)", category: .debug)
        storeImageView.setPPImage(path: imagePath)
    }
}
