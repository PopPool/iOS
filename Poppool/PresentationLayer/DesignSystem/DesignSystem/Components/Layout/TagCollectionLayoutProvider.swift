import UIKit

public struct TagCollectionLayoutProvider: CollectionLayoutProvidable, HeaderLayoutProvidable {
    public init() { }
    
    public func makeLayout() -> NSCollectionLayoutSection {
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
        section.interGroupSpacing = 6
        
        return section
    }
    
    public func makeHeaderLayout(_ elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem {
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
    
    public func configureSectionInsets(_ section: NSCollectionLayoutSection, isRecentSearch: Bool) {
        if isRecentSearch {
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 48, trailing: 20)
        } else {
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        }
    }
} 
