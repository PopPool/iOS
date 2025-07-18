import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class TagCollectionHeaderView: UICollectionReusableView {

    // MARK: - Components
    var disposeBag = DisposeBag()

    private let sectionTitleLabel = UILabel().then {
        $0.font = .korFont(style: .bold, size: 16)
    }

    let removeAllButton = UIButton().then {
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
        [sectionTitleLabel, removeAllButton].forEach {
            self.addSubview($0)
        }
    }

    func setupConstraints() {
        sectionTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }

        removeAllButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(sectionTitleLabel)
            make.height.equalTo(20)
        }
    }
}

extension TagCollectionHeaderView {
    func configureHeader(title: String, buttonTitle: String? = nil) {
        sectionTitleLabel.text = title
        if let buttonTitle = buttonTitle {
            removeAllButton.isHidden = false
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.korFont(style: .regular, size: 13)
            ]
            let attributedTitle = NSAttributedString(string: buttonTitle, attributes: attributes)
            removeAllButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }
}
