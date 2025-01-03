import UIKit
import SnapKit

final class StoreListView: UIView {
    // MARK: - Components
    lazy var collectionView: UICollectionView = {
            let layout = createLayout()
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .white
            cv.register(StoreListCell.self, forCellWithReuseIdentifier: StoreListCell.identifier)
            cv.register(
                StoreListHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: StoreListHeaderView.identifier
            )
            return cv
        }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension StoreListView {
    func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 16

        let totalWidth = UIScreen.main.bounds.width - 32
        let itemWidth = (totalWidth - layout.minimumInteritemSpacing) / 2

        layout.itemSize = CGSize(width: floor(itemWidth), height: itemWidth + 100)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        return layout
    }

    func setUpConstraints() {
        backgroundColor = .clear
        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
