import UIKit

import DesignSystem

import SnapKit

final class SearchResultView: UIView {

    // MARK: - Components
    let contentCollectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: .init())
    }()

    let emptyLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "검색 결과가 없어요:(\n다른 키워드로 검색해주세요")
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .g400
        return label
    }()

    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension SearchResultView {

    func setUpConstraints() {
        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.trailing.bottom.equalToSuperview()
        }

        self.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(contentCollectionView.snp.top).inset(193)
            make.leading.trailing.equalToSuperview()
        }
    }
}
