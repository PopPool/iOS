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
        case searchResultEmptyItem(SearchResultEmptyCollectionViewCell.EmptyCase)
    }

    /// Section의 헤더를 구분하기 위한 변수
    enum SectionHeaderKind: String {
        case recentSearch = "recentSearchElementKind"
        case category = "categoryElementKind"
        case searchResult = "searchResultElementKind"
    }

    // MARK: - Properties
    private let layoutFactory: PopupSearchLayoutFactory = PopupSearchLayoutFactory()
    let recentSearchTagRemoveButtonTapped = PublishRelay<String>()
    let recentSearchTagRemoveAllButtonTapped = PublishRelay<Void>()
    let categoryTagRemoveButtonTapped = PublishRelay<Int>()
    let filterStatusButtonTapped = PublishRelay<Void>()

    let tapGestureRecognizer = UITapGestureRecognizer().then {
        $0.cancelsTouchesInView = false
    }

    let searchBar = PPSearchBarView()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = layoutFactory.makeCollectionViewLayout { [weak self] in self?.dataSource }

        $0.setCollectionViewLayout(layout, animated: false)

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
            TagCollectionViewCell.self,
            forCellWithReuseIdentifier: TagCollectionViewCell.identifiers
        )

        $0.register(
            SearchResultHeaderView.self,
            forSupplementaryViewOfKind: SectionHeaderKind.searchResult.rawValue,
            withReuseIdentifier: SearchResultHeaderView.Identifier.searchResult.rawValue
        )

        $0.register(
            PPPopupGridCollectionViewCell.self,
            forCellWithReuseIdentifier: PPPopupGridCollectionViewCell.identifiers
        )

        $0.register(
            SearchResultEmptyCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchResultEmptyCollectionViewCell.identifiers
        )

        // UICollectionView 최 상/하단 빈 영역
        $0.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 48, right: 0)
        $0.contentInsetAdjustmentBehavior = .never
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

        [tapGestureRecognizer].forEach {
            self.addGestureRecognizer($0)
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

            case .searchResultEmptyItem(let emptyCase):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchResultEmptyCollectionViewCell.identifiers,
                    for: indexPath
                ) as! SearchResultEmptyCollectionViewCell
                cell.injection(with: SearchResultEmptyCollectionViewCell.Input(emptyCase: emptyCase))
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
                } else { header.injection(with: SearchResultHeaderView.Input(
                    title: nil,
                    count: nil, filterStatusText: nil
                ))
                }

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
        headerInput searchResultHeaderInput: SearchResultHeaderView.Input? = nil,
        searchResultEmpty: SearchResultEmptyCollectionViewCell.EmptyCase? = nil
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

        snapshot.appendSections([PopupSearchView.Section.searchResult])
        self.searchResultHeaderInput = searchResultHeaderInput

        if let searchResultEmpty {
            snapshot.appendItems([.searchResultEmptyItem(searchResultEmpty)], toSection: .searchResult)
        } else {
            snapshot.appendItems(searchResultItems, toSection: .searchResult)
        }
        snapshot.reloadSections([.searchResult])

        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func getSectionsFromDataSource() -> [Section] {
        return dataSource?.snapshot().sectionIdentifiers ?? []
    }
}
