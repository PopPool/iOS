import UIKit

import DesignSystem

import RxCocoa
import RxRelay
import RxSwift
import SnapKit
import Then

final class PopupSearchView: UIView {

    // MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<PopupSearchSection, SectionItem>?
    private let layoutFactory: PopupSearchLayoutFactory = PopupSearchLayoutFactory()

    let recentSearchTagRemoveButtonTapped = PublishRelay<String>()
    let recentSearchTagRemoveAllButtonTapped = PublishRelay<Void>()
    let categoryTagRemoveButtonTapped = PublishRelay<Int>()
    let filterStatusButtonTapped = PublishRelay<Void>()
    let bookmarkButtonTapped = PublishRelay<IndexPath>()

    let tapGestureRecognizer = UITapGestureRecognizer().then {
        $0.cancelsTouchesInView = false
    }

    public let searchBar = PPSearchBarView()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = layoutFactory.makeCollectionViewLayout { [weak self] in self?.dataSource }

        $0.setCollectionViewLayout(layout, animated: false)

        $0.register(
            TagCollectionHeaderView.self,
            forSupplementaryViewOfKind: SectionHeaderKind.recentSearch.rawValue,
            withReuseIdentifier: TagCollectionHeaderView.identifiers
        )

        $0.register(
            TagCollectionHeaderView.self,
            forSupplementaryViewOfKind: SectionHeaderKind.category.rawValue,
            withReuseIdentifier: TagCollectionHeaderView.identifiers
        )

        $0.register(
            PPTagCollectionViewCell.self,
            forCellWithReuseIdentifier: PPTagCollectionViewCell.identifiers
        )

        $0.register(
            SearchResultHeaderCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchResultHeaderCollectionViewCell.identifiers
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
            make.top.equalTo(self.safeAreaLayoutGuide)
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
        self.dataSource = UICollectionViewDiffableDataSource<
            PopupSearchSection,
            PopupSearchView.SectionItem
        >(
            collectionView: collectionView
        ) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            switch item {
            case .recentSearchItem(let item):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PPTagCollectionViewCell.identifiers,
                    for: indexPath
                ) as! PPTagCollectionViewCell

                cell.configureCell(
                    title: item.title,
                    id: item.id,
                    isSelected: item.isSelected,
                    isCancelable: item.isCancelable
                )

                cell.cancelButton.rx.tap
                    .compactMap { cell.titleLabel.text }
                    .bind(to: self.recentSearchTagRemoveButtonTapped)
                    .disposed(by: cell.disposeBag)

                return cell

            case .categoryItem(let item):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PPTagCollectionViewCell.identifiers,
                    for: indexPath
                ) as! PPTagCollectionViewCell

                cell.configureCell(
                    title: item.title,
                    id: item.id,
                    isSelected: item.isSelected,
                    isCancelable: item.isCancelable
                )

                cell.cancelButton.rx.tap
                    .compactMap { item.id }
                    .bind(to: self.categoryTagRemoveButtonTapped)
                    .disposed(by: cell.disposeBag)

                return cell

            case .searchResultHeaderItem(let item):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchResultHeaderCollectionViewCell.identifiers,
                    for: indexPath
                ) as! SearchResultHeaderCollectionViewCell

                cell.configureCell(title: item.title, count: item.count, filterText: item.filterText)

                cell.filterStatusButton.rx.tap
                    .bind(to: self.filterStatusButtonTapped)
                    .disposed(by: cell.disposeBag)

                return cell

            case .searchResultItem(let item):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PPPopupGridCollectionViewCell.identifiers,
                    for: indexPath
                ) as! PPPopupGridCollectionViewCell

                cell.configureCell(
                    imagePath: item.imagePath,
                    id: item.id,
                    category: item.category,
                    title: item.title,
                    address: item.address,
                    startDate: item.startDate,
                    endDate: item.endDate,
                    isBookmark: item.isBookmark,
                    isLogin: item.isLogin,
                    isPopular: item.isPopular,
                    row: item.row
                )

                cell.bookmarkButton.rx.tap
                    .map { indexPath }
                    .bind(to: self.bookmarkButtonTapped)
                    .disposed(by: cell.disposeBag)

                return cell

            case .searchResultEmptyItem(let title):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchResultEmptyCollectionViewCell.identifiers,
                    for: indexPath
                ) as! SearchResultEmptyCollectionViewCell

                cell.configureCell(title: title)

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
                    withReuseIdentifier: TagCollectionHeaderView.identifiers,
                    for: indexPath
                ) as? TagCollectionHeaderView else { fatalError("\(#file), \(#function) Error") }
                header.configureHeader(title: "최근 검색어", buttonTitle: "모두삭제")

                header.removeAllButton.rx.tap
                    .bind(to: self.recentSearchTagRemoveAllButtonTapped)
                    .disposed(by: header.disposeBag)

                return header

            case .category:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: TagCollectionHeaderView.identifiers,
                    for: indexPath
                ) as? TagCollectionHeaderView else { fatalError("\(#file), \(#function) Error") }
                header.configureHeader(title: "팝업스토어 찾기")

                return header
            }
        }
    }

    func updateSectionSnapshot(at section: PopupSearchSection, with items: [SectionItem]) {
        if items.isEmpty {
            guard var snapshot = dataSource?.snapshot() else { return }
            snapshot.deleteSections([section])
            dataSource?.apply(snapshot, animatingDifferences: false)
            return
        } else {
            if var snapshot = dataSource?.snapshot(for: section) {
                snapshot.deleteAll()
                snapshot.append(items)
                dataSource?.apply(snapshot, to: section)
            } else {
                guard var snapshot = dataSource?.snapshot() else { return }
                snapshot.appendSections([section])
                snapshot.appendItems(items, toSection: section)
                dataSource?.apply(snapshot)
            }
        }
    }

    func updateSearchResultSectionSnapshot(
        with items: [SectionItem],
        header: SectionItem,
        empty: SectionItem? = nil
    ) {
        guard var snapshot = dataSource?.snapshot() else { return }

        snapshot.deleteSections([.searchResultHeader, .searchResult])

        snapshot.appendSections( [.searchResultHeader, .searchResult])
        snapshot.appendItems([header], toSection: .searchResultHeader)

        if let empty {
            snapshot.appendItems([empty], toSection: .searchResult)
        } else {
            snapshot.appendItems(items, toSection: .searchResult)
        }

        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func getSectionsFromDataSource() -> [PopupSearchSection] {
        return dataSource?.snapshot().sectionIdentifiers ?? []
    }
}

// MARK: - Section information
extension PopupSearchView {
    /// Section에 들어갈 Item을 정의한 변수
    enum SectionItem: Hashable {
        case recentSearchItem(TagModel)
        case categoryItem(TagModel)
        case searchResultHeaderItem(SearchResultHeaderModel)
        case searchResultItem(SearchResultModel)
        case searchResultEmptyItem(String)
    }

    /// Section의 헤더를 구분하기 위한 변수
    enum SectionHeaderKind: String {
        case recentSearch = "recentSearchElementKind"
        case category = "categoryElementKind"
    }
}
