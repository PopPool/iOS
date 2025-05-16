import UIKit

// MARK: - Layout

    func makeCollectionViewLayout(
        dataSourceProvider: @escaping () -> UICollectionViewDiffableDataSource<PopupSearchSection, PopupSearchView.SectionItem>?
    ) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let self = self,
                  let dataSource = dataSourceProvider() else { return nil }
struct PopupSearchLayoutFactory {

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
                return makeSearchResultSectionLayout()

            case .searchResultEmpty:
                return makeSearchResultEmptySectionLayout()
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

    func makeSearchResultSectionLayout() -> NSCollectionLayoutSection {
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 24

        return section
    }

    func makeSearchResultEmptySectionLayout() -> NSCollectionLayoutSection {

        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)

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
