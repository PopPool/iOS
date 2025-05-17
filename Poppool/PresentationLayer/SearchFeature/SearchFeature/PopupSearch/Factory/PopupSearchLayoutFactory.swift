import UIKit
import DesignSystem

// MARK: - Layout
struct PopupSearchLayoutFactory {
    private let tagLayoutProvider = TagCollectionLayoutProvider()
    private let gridLayoutProvider = GridCollectionLayoutProvider()
    
    private var sectionProvider: ((Int) -> PopupSearchSection?)?
    
    mutating func setSectionProvider(_ provider: @escaping (Int) -> PopupSearchSection?) {
        self.sectionProvider = provider
    }

    func makeCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            sectionIndex,
            environment -> NSCollectionLayoutSection? in
            guard let sectionType = sectionProvider?(sectionIndex) else { return nil }

            switch sectionType {
            case .recentSearch:
                let layout = self.tagLayoutProvider.makeLayout()
                layout.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 48, trailing: 20)
                layout.boundarySupplementaryItems = [
                    self.tagLayoutProvider.makeHeaderLayout(
                        PopupSearchView.SectionHeaderKind.recentSearch.rawValue
                    )
                ]
                return layout
                
            case .category:
                let layout = self.tagLayoutProvider.makeLayout()
                layout.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
                layout.boundarySupplementaryItems = [
                    self.tagLayoutProvider.makeHeaderLayout(
                        PopupSearchView.SectionHeaderKind.category.rawValue
                    )
                ]
                return layout
                
            case .searchResultHeader:
                return makeSearchResultHeaderSectionLayout()
                
            case .searchResult:
                return self.gridLayoutProvider.makeLayout()
                
            case .searchResultEmpty:
                return makeSearchResultEmptySectionLayout()
            }
        }
    }
    
    private func makeSearchResultHeaderSectionLayout() -> NSCollectionLayoutSection {
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

    private func makeSearchResultEmptySectionLayout() -> NSCollectionLayoutSection {
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
}
