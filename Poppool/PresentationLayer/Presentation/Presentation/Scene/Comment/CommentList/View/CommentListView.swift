import UIKit

import DesignSystem

import SnapKit

final class CommentListView: UIView {

    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        return PPReturnHeaderView()
    }()

    let contentCollectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: .init())
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
private extension CommentListView {

    func setUpConstraints() {

        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
