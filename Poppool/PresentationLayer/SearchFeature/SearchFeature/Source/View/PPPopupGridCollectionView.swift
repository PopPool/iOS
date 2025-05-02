import UIKit

import SnapKit

public final class PPPopupGridCollecView: UICollectionView {
    // MARK: - Properties

    // MARK: - init
    public init() {
        super.init(frame: .zero, collectionViewLayout: Self.makeLayout())

        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension PPPopupGridCollecView {
    func addViews() { }

    func setupConstraints() { }

    func configureUI() { }
}

// MARK: - Layout
private extension PPPopupGridCollecView {
    static func makeLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(249)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(249)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item, item]
            )
            group.interItemSpacing = .fixed(16)

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.interGroupSpacing = 24

            return section
        }
    }
}
