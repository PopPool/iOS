import UIKit

import SnapKit

public final class PPPopupGridCollecView: UICollectionView {
    // MARK: - Properties

    public enum Section: Int, CaseIterable {
        case main
    }

    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<Section, PPPopupGridCollectionViewCell.Input> = {
        return UICollectionViewDiffableDataSource<Section, PPPopupGridCollectionViewCell.Input>(collectionView: self) { collectionView, indexPath, model in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PPPopupGridCollectionViewCell.identifiers,
                for: indexPath
            ) as! PPPopupGridCollectionViewCell
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
        _ models: [PPPopupGridCollectionViewCell.Input],
        animating: Bool = true
    ) {
        var snapshot = diffableDataSource.snapshot()
        snapshot.appendItems(models, toSection: .main)
        diffableDataSource.apply(snapshot, animatingDifferences: animating)
    }
}

// MARK: - SetUp
private extension PPPopupGridCollecView {
    func addViews() {
        self.register(
            PPPopupGridCollectionViewCell.self,
            forCellWithReuseIdentifier: PPPopupGridCollectionViewCell.identifiers
        )
    }

    func configureUI() {
        super.dataSource = diffableDataSource
    }
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
