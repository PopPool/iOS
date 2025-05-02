import UIKit

import SnapKit

public final class TagCollectionView: UICollectionView {
    // MARK: - Properties

    public enum Section: Int, CaseIterable {
        case main
    }

    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<Section, TagCollectionViewCell.Input> = {
        return UICollectionViewDiffableDataSource<Section, TagCollectionViewCell.Input>(collectionView: self) { collectionView, indexPath, model in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TagCollectionViewCell.identifiers,
                for: indexPath
            ) as! TagCollectionViewCell
            cell.injection(with: model)
            return cell
        }
    }()

    // MARK: - init
    public init() {
        super.init(frame: .zero, collectionViewLayout: Self.makeLayout())

        self.addViews()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }

    /// 모델을 입력받으면 collectionView를 업데이트함
    public func apply(
        _ models: [TagCollectionViewCell.Input],
        animating: Bool = true
    ) {
        var snapshot = diffableDataSource.snapshot()
        snapshot.appendItems(models, toSection: .main)
        diffableDataSource.apply(snapshot, animatingDifferences: animating)
    }
}

// MARK: - SetUp
private extension TagCollectionView {
    func addViews() {
        self.register(
            TagCollectionViewCell.self,
            forCellWithReuseIdentifier: TagCollectionViewCell.identifiers
        )
    }

    func configureUI() {
        super.dataSource = diffableDataSource
    }
}

// MARK: - Layout
private extension TagCollectionView {
    static func makeLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(100),
                heightDimension: .absolute(31)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(31)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
            section.interGroupSpacing = 6

            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(24)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: Self.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            return section
        }
    }
}
