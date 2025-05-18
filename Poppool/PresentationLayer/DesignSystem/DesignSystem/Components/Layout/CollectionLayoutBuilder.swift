import UIKit

public final class CollectionLayoutBuilder {
    private var itemSize: NSCollectionLayoutSize?
    private var groupSize: NSCollectionLayoutSize?
    private var numberOfItemsPerGroup: Int = 1
    private var interItemSpacing: NSCollectionLayoutSpacing?
    private var section: NSCollectionLayoutSection?
    private var headerItem: NSCollectionLayoutBoundarySupplementaryItem?

    public init() { }

    public init(section existingSection: NSCollectionLayoutSection) {
        self.section = existingSection
    }

    @discardableResult
    public func item(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension
    ) -> Self {
        itemSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )

        return self
    }

    @discardableResult
    public func group(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension
    ) -> Self {
        groupSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )

        return self
    }

    @discardableResult
    public func numberOfItemsPerGroup(_ count: Int) -> Self {
        numberOfItemsPerGroup = count

        return self
    }

    @discardableResult
    public func itemSpacing(_ spacing: CGFloat) -> Self {
        interItemSpacing = .fixed(spacing)

        return self
    }

    @discardableResult
    public func withContentInsets(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) -> Self {
        section?.contentInsets = NSDirectionalEdgeInsets(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )

        return self
    }

    @discardableResult
    public func composeSection(_ axis: UIAxis) -> Self {
        guard let itemSize, let groupSize else {
            fatalError("Item and Group must be set before creating section")
        }

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        var group: NSCollectionLayoutGroup!

        switch axis {
        case .vertical:
            group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: Array(repeating: item, count: numberOfItemsPerGroup)
            )

        case .horizontal:
            group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: Array(repeating: item, count: numberOfItemsPerGroup)
            )

        default: fatalError("Can't compose section to selected axis")
        }

        if let interItemSpacing {
            group.interItemSpacing = interItemSpacing
        }

        section = NSCollectionLayoutSection(group: group)

        return self
    }

    @discardableResult
    public func header(
        elementKind: String,
        width: NSCollectionLayoutDimension = .fractionalWidth(1.0),
        height: NSCollectionLayoutDimension = .fractionalHeight(1.0),
        alignment: NSRectAlignment = .top
    ) -> Self {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )

        headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: elementKind,
            alignment: alignment
        )

        if let headerItem {
            section?.boundarySupplementaryItems = [headerItem]
        }

        return self
    }

    @discardableResult
    public func withScrollingBehavior(_ behavior: UICollectionLayoutSectionOrthogonalScrollingBehavior) -> Self {
        section?.orthogonalScrollingBehavior = behavior

        return self
    }

    @discardableResult
    public func groupSpacing(_ spacing: CGFloat) -> Self {
        section?.interGroupSpacing = spacing

        return self
    }

    @discardableResult
    public func modifySection(_ modifier: (NSCollectionLayoutSection) -> Void) -> Self {
        if let section = self.section {
            modifier(section)
        }
        return self
    }

    @discardableResult
    public func withExistingHeader(_ headerItem: NSCollectionLayoutBoundarySupplementaryItem) -> Self {
        self.headerItem = headerItem

        if let section = self.section {
            section.boundarySupplementaryItems = [headerItem]
        }

        return self
    }

    @discardableResult
    public func header(_ headerItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> Self {
        if let section = self.section {
            section.boundarySupplementaryItems = headerItems
        }

        return self
    }

    public func build() -> NSCollectionLayoutSection {
        guard let section else { fatalError("Section must be created before building") }
        return section
    }

    public func buildHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        guard let headerItem else { fatalError("Header must be created before building") }
        return headerItem
    }
}
