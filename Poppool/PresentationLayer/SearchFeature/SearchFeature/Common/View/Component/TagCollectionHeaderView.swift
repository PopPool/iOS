import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class TagCollectionHeaderView: UICollectionReusableView {

    // MARK: - Components
    var disposeBag = DisposeBag()

    private let sectionTitleLabel = PPLabel(text: "최근 검색어", style: .KOb16)

    let removeAllButton = UIButton().then {
        $0.isHidden = true
        $0.setText(to: "모두삭제", with: .KOr13)
    }

    private let removeAllButtonUnderline = UIView().then {
        $0.backgroundColor = .g1000
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

        [removeAllButtonUnderline].forEach {
            removeAllButton.addSubview($0)
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

        removeAllButtonUnderline.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
    }
}

extension TagCollectionHeaderView {
    func configureHeader(title: String, showRemoveAllButton: Bool = false) {
        sectionTitleLabel.updateText(to: title)
        removeAllButton.isHidden = !showRemoveAllButton
    }
}
