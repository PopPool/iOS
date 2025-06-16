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
        return UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in

            guard let sectionType = sectionProvider?(sectionIndex) else { return nil }

            switch sectionType {
            case .recentSearch:
                return makeRecentSearchSectionLayout()

            case .category:
                return makeCategorySectionLayout()

            case .searchResultHeader:
                return makeSearchResultHeaderSectionLayout()

            case .searchResult:
                return self.gridLayoutProvider.makeLayout()

            case .searchResultEmpty:
                return makeSearchResultEmptySectionLayout()
            }
        }
    }

    private func makeRecentSearchSectionLayout() -> NSCollectionLayoutSection {

        return CollectionLayoutBuilder(section: tagLayoutProvider.makeLayout())
            .withContentInsets(top: 16, leading: 20, bottom: 48, trailing: 20)
            .header([self.tagLayoutProvider.makeHeaderLayout(
                PopupSearchView.SectionHeaderKind.recentSearch.rawValue
            )])
            .build()
    }

    private func makeCategorySectionLayout() -> NSCollectionLayoutSection {

        return CollectionLayoutBuilder(section: tagLayoutProvider.makeLayout())
            .withContentInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
            .header([
                tagLayoutProvider.makeHeaderLayout(PopupSearchView.SectionHeaderKind.category.rawValue)
            ])
            .build()
    }

    private func makeSearchResultHeaderSectionLayout() -> NSCollectionLayoutSection {

        return CollectionLayoutBuilder()
            .item(width: .fractionalWidth(1.0), height: .estimated(22))
            .group(width: .fractionalWidth(1.0), height: .estimated(22))
            .composeSection(.horizontal)
            .withContentInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            .build()
    }

    private func makeSearchResultEmptySectionLayout() -> NSCollectionLayoutSection {

        return CollectionLayoutBuilder()
            .item(width: .fractionalWidth(1.0), height: .fractionalHeight(1.0))
            .group(width: .fractionalWidth(1.0), height: .fractionalHeight(1.0))
            .composeSection(.vertical)
            .build()
    }
}
