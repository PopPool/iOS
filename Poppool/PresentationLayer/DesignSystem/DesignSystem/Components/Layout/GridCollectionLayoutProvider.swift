import UIKit

public struct GridCollectionLayoutProvider: CollectionLayoutProvidable {
    public init() { }

    public func makeLayout() -> NSCollectionLayoutSection {
        return CollectionLayoutBuilder()
            .item(width: .fractionalWidth(0.5), height: .absolute(249))
            .group(width: .fractionalWidth(1.0), height: .absolute(249))
            .numberOfItemsPerGroup(2)
            .itemSpacing(16)
            .composeSection(.horizontal)
            .withContentInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
            .groupSpacing(24)
            .build()
    }
}
