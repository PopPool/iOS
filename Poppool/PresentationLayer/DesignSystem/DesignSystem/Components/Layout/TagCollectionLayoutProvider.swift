import UIKit

public struct TagCollectionLayoutProvider: CollectionLayoutProvidable, HeaderLayoutProvidable {
    public init() { }

    public func makeLayout() -> NSCollectionLayoutSection {
        return CollectionLayoutBuilder()
            .item(width: .estimated(100), height: .absolute(31))
            .group(width: .estimated(100), height: .estimated(31))
            .composeSection(.vertical)
            .withScrollingBehavior(.continuous)
            .groupSpacing(6)
            .build()
    }

    public func makeHeaderLayout(_ elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem {
        return CollectionLayoutBuilder()
            .header(elementKind: elementKind, height: .absolute(24))
            .buildHeader()
    }
}
