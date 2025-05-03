import UIKit

import SnapKit
import Then

final class PopupSearchView: UIView {
    enum Section: CaseIterable, Hashable {
        case recentSearch
        case category
        case searchResult
    }

    enum SectionItem: Hashable {
        case recentSearchItem(TagCollectionViewCell.Input)
        case categoryItem(TagCollectionViewCell.Input)
        case searchResultItem(PPPopupGridCollectionViewCell.Input)
    }

    enum SectionHeaderKind: String, CaseIterable {
        case recentSearch = "recentSearchElementKind"
        case category = "categoryElementKind"
    }

    // MARK: - Properties
    let searchBar = PPSearchBarView()
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: PopupSearchView.makeLayout()
    ).then {
        $0.register(
            TagCollectionViewCell.self,
            forCellWithReuseIdentifier: TagCollectionViewCell.identifiers
        )

        $0.register(
            PPPopupGridCollectionViewCell.self,
            forCellWithReuseIdentifier: PPPopupGridCollectionViewCell.identifiers
        )

        $0.register(
            TagCollectionHeaderView.self,
            forSupplementaryViewOfKind: SectionHeaderKind.recentSearch.rawValue,
            withReuseIdentifier: TagCollectionHeaderView.Identifier.recentSearch.identifer
        )

        $0.register(
            TagCollectionHeaderView.self,
            forSupplementaryViewOfKind: SectionHeaderKind.category.rawValue,
            withReuseIdentifier: TagCollectionHeaderView.Identifier.category.identifer
        )
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, SectionItem>?

    // MARK: - init
    init() {
        super.init(frame: .zero)

        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension PopupSearchView {
    func addViews() {
        [searchBar, collectionView].forEach {
            self.addSubview($0)
        }
    }

    func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(12)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configureUI() {
        self.searchBar.backgroundColor = .yellow
        self.collectionView.backgroundColor = UIColor.green

        self.configurationDataSourceItem()
        self.configureDataSourceHeader()
    }
}

// MARK: - Layout
private extension PopupSearchView {
    static func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch Section.allCases[sectionIndex] {
            case .recentSearch: return self.makeTagSectionLayout(SectionHeaderKind.recentSearch.rawValue)
            case .category: return self.makeTagSectionLayout(SectionHeaderKind.category.rawValue)
            case .searchResult: return self.makeSearchResultSectionLayout()
            }
        }
    }

    static func makeTagSectionLayout(_ headerKind: String) -> NSCollectionLayoutSection {
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

        section.boundarySupplementaryItems = [makeHeaderLayout(headerKind)]

        return section
    }

    static func makeSearchResultSectionLayout() -> NSCollectionLayoutSection {
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

    static func makeHeaderLayout(_ elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem {
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(24)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: elementKind,
            alignment: .top
        )

        return header
    }
}

// MARK: - DataSource
extension PopupSearchView {
    private func configurationDataSourceItem() {
        print("HEADER DEBUG:", #function, #line, "data source is", self.dataSource == nil)
        self.dataSource = UICollectionViewDiffableDataSource<PopupSearchView.Section, PopupSearchView.SectionItem>(
            collectionView: collectionView
        ) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .recentSearchItem(let recentRearchItem):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TagCollectionViewCell.identifiers,
                    for: indexPath
                ) as! TagCollectionViewCell
                cell.injection(with: recentRearchItem)
                return cell

            case .categoryItem(let categoryItem):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TagCollectionViewCell.identifiers,
                    for: indexPath
                ) as! TagCollectionViewCell
                cell.injection(with: categoryItem)
                return cell

            case .searchResultItem(let searchResultItem):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PPPopupGridCollectionViewCell.identifiers,
                    for: indexPath
                ) as! PPPopupGridCollectionViewCell
                cell.injection(with: searchResultItem)
                return cell
            }
        }

        print("HEADER DEBUG:", #function, #line, "data source is", self.dataSource == nil)

        self.collectionView.dataSource = self.dataSource
    }

    private func configureDataSourceHeader() {
        print("HEADER DEBUG:", #function, #line)
        dataSource?.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in

            print("HEADER DEBUG:", #function, #line, "elementKind is", elementKind)

            switch SectionHeaderKind(rawValue: elementKind)! {
            case .recentSearch:
                print("HEADER DEBUG:", #function, #line)
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: TagCollectionHeaderView.Identifier.recentSearch.identifer,
                    for: indexPath
                ) as? TagCollectionHeaderView else { fatalError("\(#file), \(#function) Error")}
                header.setupHeader(title: "최근 검색어", buttonTitle: "모두삭제")

                return header

            case .category:
                print("HEADER DEBUG:", #function, #line)
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: TagCollectionHeaderView.Identifier.category.identifer,
                    for: indexPath
                ) as? TagCollectionHeaderView else { fatalError("\(#file), \(#function) Error")}
                header.setupHeader(title: "팝업스토어 찾기")

                return header
            }
        }
    }

    func updateSnapshot(
        recentSearchItems: [SectionItem],
        categoryItems: [SectionItem],
        searchResultItems: [SectionItem]
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<PopupSearchView.Section, PopupSearchView.SectionItem>()
        snapshot.appendSections(PopupSearchView.Section.allCases)
        snapshot.appendItems(recentSearchItems, toSection: .recentSearch)
        snapshot.appendItems(categoryItems, toSection: .category)
        snapshot.appendItems(searchResultItems, toSection: .searchResult)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
