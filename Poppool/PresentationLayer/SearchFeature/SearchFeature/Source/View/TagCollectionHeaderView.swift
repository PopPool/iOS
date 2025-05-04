import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class TagCollectionHeaderView: UICollectionReusableView {

    enum Identifier: String {
        case recentSearch = "TagCollectionHeaderView.recentSearch"
        case category = "TagCollectionHeaderView.category"
    }

    // MARK: - Components
    var disposeBag = DisposeBag()

    private let sectionTitleLabel = UILabel().then {
        $0.font = .korFont(style: .bold, size: 16)
    }

    let titleButton = UIButton().then {
        $0.isHidden = true

    }
    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addViews()
        self.setupConstraints()
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
private extension TagCollectionHeaderView {
    func addViews() {
        [sectionTitleLabel, titleButton].forEach {
            self.addSubview($0)
        }
    }

    func setupConstraints() {
        sectionTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }

        titleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(sectionTitleLabel)
            make.height.equalTo(20)
        }
    }
}

extension TagCollectionHeaderView {
    func setupHeader(title: String, buttonTitle: String? = nil) {
        sectionTitleLabel.text = title
        if let buttonTitle = buttonTitle {
            titleButton.isHidden = false
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.korFont(style: .regular, size: 13)
            ]
            let attributedTitle = NSAttributedString(string: buttonTitle, attributes: attributes)
            titleButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }
}
