import UIKit

import DesignSystem

import ReactorKit
import RxSwift
import SnapKit
import Then

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

    private let categoryTagLabel = PPLabel(style: .KOb11).then {
        $0.textColor = .blu500
    }

    private let titleLabel = PPLabel(style: .KOb14).then {
        $0.textColor = .g900
        $0.numberOfLines = 2
    }

    private let locationLabel = PPLabel(style: .KOm11).then {
        $0.textColor = .g400
        $0.numberOfLines = 2
    }

    private let dateLabel = PPLabel(style: .KOr12).then {
        $0.textColor = .g400
        $0.numberOfLines = 2
    }

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
        //        backgroundColor = .white
    }

    func setUpConstraints() {
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.width - 48) / 2)
            make.height.equalTo(thumbnailImageView.snp.width)
        }

        contentView.addSubview(bookmarkButton)
        bookmarkButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.size.equalTo(24)
        }

        contentView.addSubview(categoryTagLabel)
           contentView.addSubview(titleLabel)
           contentView.addSubview(locationLabel)
           contentView.addSubview(dateLabel)

           // 각 라벨의 위치 설정
           categoryTagLabel.snp.makeConstraints { make in
               make.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
               make.leading.trailing.equalToSuperview()
               make.height.equalTo(16)
           }

           titleLabel.snp.makeConstraints { make in
               make.top.equalTo(categoryTagLabel.snp.bottom).offset(6)
               make.leading.trailing.equalToSuperview()
           }

           locationLabel.snp.makeConstraints { make in
               make.top.equalTo(titleLabel.snp.bottom).offset(12)
               make.leading.trailing.equalToSuperview()
           }

           dateLabel.snp.makeConstraints { make in
               make.top.equalTo(locationLabel.snp.bottom).offset(6)
               make.leading.trailing.equalToSuperview()
               make.bottom.lessThanOrEqualToSuperview()
           }
       }
}

// MARK: - Inputable
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
        thumbnailImageView.setPPImage(path: input.thumbnailURL)
        categoryTagLabel.updateText(to: "#\(input.category)")
        titleLabel.updateText(to: input.title)
        locationLabel.updateText(to: input.location)
        dateLabel.updateText(to: input.date)

        let bookmarkImage = input.isBookmarked ? "icon_bookmark_fill" : "icon_bookmark"
        bookmarkButton.setImage(UIImage(named: bookmarkImage), for: .normal)
    }
}
