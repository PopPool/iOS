import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxRelay

final class PopupSearchView: UIView {
    /// View를 구성하는 section을 정의
    enum Section: CaseIterable, Hashable {
        case recentSearch
        case category
        case searchResult
    }

    /// Section에 들어갈 Item을 정의한 변수
    enum SectionItem: Hashable {
        case recentSearchItem(TagCollectionViewCell.Input)
        case categoryItem(TagCollectionViewCell.Input)
        case searchResultItem(PPPopupGridCollectionViewCell.Input)
    }

    /// Section의 헤더를 구분하기 위한 변수
    enum SectionHeaderKind: String {
        case recentSearch = "recentSearchElementKind"
        case category = "categoryElementKind"
        case searchResult = "searchResultElementKind"
    }

    // MARK: - Properties
    let recentSearchTagRemoveButtonTapped = PublishRelay<String>()
    let recentSearchTagRemoveAllButtonTapped = PublishRelay<Void>()
    let categoryTagRemoveButtonTapped = PublishRelay<Int>()
    let filterStatusButtonTapped = PublishRelay<Void>()
    let tapGestureRecognizer = UITapGestureRecognizer()

    let searchBar = PPSearchBarView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.setCollectionViewLayout(self.makeLayout(), animated: false)

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
            withReuseIdentifier: TagCollectionHeaderView.Identifier.recentSearch.rawValue
        )

        $0.register(
            TagCollectionHeaderView.self,
            forSupplementaryViewOfKind: SectionHeaderKind.category.rawValue,
            withReuseIdentifier: TagCollectionHeaderView.Identifier.category.rawValue
        )
        $0.register(
            SearchResultHeaderView.self,
            forSupplementaryViewOfKind: SectionHeaderKind.searchResult.rawValue,
            withReuseIdentifier: SearchResultHeaderView.Identifier.searchResult.rawValue
        )

        // UICollectionView 최 상/하단 빈 영역
        $0.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 48, right: 0)
        $0.contentInsetAdjustmentBehavior = .never

        $0.addGestureRecognizer(tapGestureRecognizer)
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, SectionItem>?
    private var searchResultHeaderInput: SearchResultHeaderView.Input?

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
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configureUI() {
        self.configurationDataSourceItem()
        self.configureDataSourceHeader()
    }
}

// MARK: - Layout
private extension PopupSearchView {
    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self else { return nil }

            let sections = getSectionsFromDataSource()
            guard sectionIndex < sections.count else { return nil }

            switch sections[sectionIndex] {
            case .recentSearch:
                return makeTagSectionLayout(SectionHeaderKind.recentSearch.rawValue)

            case .category:
                return makeTagSectionLayout(SectionHeaderKind.category.rawValue)

            case .searchResult:
                return makeSearchResultSectionLayout(SectionHeaderKind.searchResult.rawValue)
            }
        }
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

        if headerKind == SectionHeaderKind.recentSearch.rawValue {
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 48, trailing: 20)
        } else {
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        }

        section.interGroupSpacing = 6

        section.boundarySupplementaryItems = [makeTagCollectionHeaderLayout(headerKind)]

        return section
    }

    func makeSearchResultSectionLayout(_ headerKind: String) -> NSCollectionLayoutSection {
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

        section.boundarySupplementaryItems = [makePopupGridCollectionHeaderLayout(headerKind)]

        return section
    }

    func makeTagCollectionHeaderLayout(_ elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem {
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

    func makePopupGridCollectionHeaderLayout(_ elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem {
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(22)
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

                cell.cancelButton.rx.tap
                    .compactMap { cell.titleLabel.text }
                    .bind(to: self.recentSearchTagRemoveButtonTapped)
                    .disposed(by: cell.disposeBag)

                return cell

            case .categoryItem(let categoryItem):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TagCollectionViewCell.identifiers,
                    for: indexPath
                ) as! TagCollectionViewCell
                cell.injection(with: categoryItem)

                cell.cancelButton.rx.tap
                    .compactMap { categoryItem.id }
                    .bind(to: self.categoryTagRemoveButtonTapped)
                    .disposed(by: cell.disposeBag)

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

        self.collectionView.dataSource = self.dataSource
    }

    private func configureDataSourceHeader() {
        dataSource?.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self else { return nil }
            switch SectionHeaderKind(rawValue: elementKind)! {
            case .recentSearch:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: TagCollectionHeaderView.Identifier.recentSearch.rawValue,
                    for: indexPath
                ) as? TagCollectionHeaderView else { fatalError("\(#file), \(#function) Error") }
                header.setupHeader(title: "최근 검색어", buttonTitle: "모두삭제")

                header.removeAllButton.rx.tap
                    .bind(to: self.recentSearchTagRemoveAllButtonTapped)
                    .disposed(by: header.disposeBag)

                return header

            case .category:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: TagCollectionHeaderView.Identifier.category.rawValue,
                    for: indexPath
                ) as? TagCollectionHeaderView else { fatalError("\(#file), \(#function) Error") }
                header.setupHeader(title: "팝업스토어 찾기")

                return header

            case .searchResult:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: SearchResultHeaderView.Identifier.searchResult.rawValue,
                    for: indexPath
                ) as? SearchResultHeaderView else { fatalError("\(#file), \(#function) Error") }

                if let input = self.searchResultHeaderInput {
                    header.injection(with: input)
                } else { header.injection(with: SearchResultHeaderView.Input(count: 0, filterStatusTitle: "nil")) }

                header.filterStatusButton.rx.tap
                    .bind(to: self.filterStatusButtonTapped)
                    .disposed(by: header.disposeBag)

                return header
            }
        }
    }

    func updateSnapshot(
        recentSearchItems: [SectionItem],
        categoryItems: [SectionItem],
        searchResultItems: [SectionItem],
        headerInput searchResultHeaderInput: SearchResultHeaderView.Input? = nil
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<PopupSearchView.Section, PopupSearchView.SectionItem>()

        if !recentSearchItems.isEmpty {
            snapshot.appendSections([PopupSearchView.Section.recentSearch])
            snapshot.appendItems(recentSearchItems, toSection: .recentSearch)
        }

        if !categoryItems.isEmpty {
            snapshot.appendSections([PopupSearchView.Section.category])
            snapshot.appendItems(categoryItems, toSection: .category)
        }

        if !searchResultItems.isEmpty {
            self.searchResultHeaderInput = searchResultHeaderInput
            snapshot.appendSections([PopupSearchView.Section.searchResult])
            snapshot.appendItems(searchResultItems, toSection: .searchResult) 
            snapshot.reloadSections([.searchResult])
        }

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    func getSectionsFromDataSource() -> [Section] {
        return dataSource?.snapshot().sectionIdentifiers ?? []
    }
}
