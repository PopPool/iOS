import UIKit

// MARK: - Layout
final class PopupSearchLayoutFactory {

    func makeCollectionViewLayout(
        dataSourceProvider: @escaping () -> UICollectionViewDiffableDataSource<PopupSearchView.Section, PopupSearchView.SectionItem>?
    ) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let self = self,
                  let dataSource = dataSourceProvider() else { return nil }

           // sectionIndex를 사용하여 현재 dataSource에서 Section 타입을 가져옴
           guard sectionIndex < dataSource.snapshot().numberOfSections,
                 let sectionType = dataSource.sectionIdentifier(for: sectionIndex) else { return nil }

            switch sectionType {
            case .recentSearch:
                return makeTagSectionLayout(PopupSearchView.SectionHeaderKind.recentSearch.rawValue)

            case .category:
                return makeTagSectionLayout(PopupSearchView.SectionHeaderKind.category.rawValue)

            case .searchResultHeader:
                return makeSearchResultHeaderSectionLayout()

            case .searchResult:
                let sectionSnapshot = dataSource.snapshot(for: sectionType)
                let hasEmptyItem = sectionSnapshot.items.contains { item in
                    if case .searchResultEmptyItem = item { return true }
                    return false
                }
                return makeSearchResultSectionLayout(hasEmptyItem: hasEmptyItem)
            }
        })
    }

    func makeTagSectionLayout(_ headerKind: String) -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(31)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .estimated(31)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous

        if headerKind == PopupSearchView.SectionHeaderKind.recentSearch.rawValue {
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 48, trailing: 20)
        } else {
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        }

        section.interGroupSpacing = 6

        section.boundarySupplementaryItems = [makeTagCollectionHeaderLayout(headerKind)]

        return section
    }

    func makeSearchResultHeaderSectionLayout() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(22)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(22)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        return section
    }

    func makeSearchResultSectionLayout(hasEmptyItem: Bool) -> NSCollectionLayoutSection {
        let itemWidth: NSCollectionLayoutDimension = hasEmptyItem ? .fractionalWidth(1.0) : .fractionalWidth(0.5)

        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: itemWidth,
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 24

        return section
    }

    func makeTagCollectionHeaderLayout(_ elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem {
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(24)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: elementKind,
            alignment: .top
        )
    }
}
