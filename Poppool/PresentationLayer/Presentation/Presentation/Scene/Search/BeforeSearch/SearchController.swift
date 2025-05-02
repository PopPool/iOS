import UIKit

import DesignSystem

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit

final class SearchController: BaseViewController, View {

    typealias Reactor = SearchReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = SearchView()
    private var sections: [any Sectionable] = []
    private let cellTapped: PublishSubject<IndexPath> = .init()
    private let loadNextPage = PublishSubject<Void>()
}

// MARK: - Life Cycle
extension SearchController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addViews()
        self.setupContstraints()
        self.configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - SetUp
private extension SearchController {
    func addViews() {
        [mainView].forEach {
            self.view.addSubview($0)
        }
    }

    func setupContstraints() {
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func configureUI() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }

        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self

        mainView.contentCollectionView.register(
            SearchTitleSectionCell.self,
            forCellWithReuseIdentifier: SearchTitleSectionCell.identifiers
        )

        mainView.contentCollectionView.register(
            SpacingSectionCell.self,
            forCellWithReuseIdentifier: SpacingSectionCell.identifiers
        )

        mainView.contentCollectionView.register(
            CancelableTagSectionCell.self,
            forCellWithReuseIdentifier: CancelableTagSectionCell.identifiers
        )

        mainView.contentCollectionView.register(
            SearchCountTitleSectionCell.self,
            forCellWithReuseIdentifier: SearchCountTitleSectionCell.identifiers
        )

        mainView.contentCollectionView.register(
            HomeCardSectionCell.self,
            forCellWithReuseIdentifier: HomeCardSectionCell.identifiers
        )
    }
}

// MARK: - Methods
extension SearchController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        cellTapped
            .withUnretained(self)
            .map({ (owner, indexPath) in
                Reactor.Action.cellTapped(indexPath: indexPath, controller: owner)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        loadNextPage
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
            .map { Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .filter { $0.newBottomSearchList.isEmpty && $0.bottomSearchListLastIndexPath == nil }
            .withUnretained(self)
            .subscribe { owner, state in
                owner.sections = state.sections
                owner.mainView.contentCollectionView.reloadData()
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { (sections: $0.sections,
                    newItems: $0.newBottomSearchList,
                    indexPath: $0.bottomSearchListLastIndexPath) }
            .filter { !$0.newItems.isEmpty && $0.indexPath != nil }
            .withUnretained(self)
            .subscribe { (owner, subscribeResponse) in
                let (updatedSections, newPopUpItems, popUpGridindexPath) = subscribeResponse
                guard let popUpGridindexPath = popUpGridindexPath else { return }

                let start = popUpGridindexPath.item
                let count = newPopUpItems.count
                let section = popUpGridindexPath.section
                let indexPaths = (start..<start+count).map {
                    IndexPath(item: $0, section: section)
                }

                owner.mainView.contentCollectionView.performBatchUpdates {
                    // 데이터 모델을 업데이트한 뒤 삽입
                    owner.sections = updatedSections
                    owner.mainView.contentCollectionView.insertItems(at: indexPaths)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].dataCount
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = sections[indexPath.section].getCell(collectionView: collectionView, indexPath: indexPath)
        guard let userDefaultService = reactor?.userDefaultService else { return cell }
        let searchList = userDefaultService.fetchArray(key: "searchList") ?? []
        guard let reactor = reactor else { return cell }

        if let cell = cell as? SearchTitleSectionCell {
            cell.titleButton.rx.tap
                .map { Reactor.Action.recentSearchListAllDeleteButtonTapped }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        if let cell = cell as? CancelableTagSectionCell {
            if searchList.isEmpty {
                cell.cancelButton.rx.tap
                    .map { Reactor.Action.categoryDelteButtonTapped(indexPath: indexPath)}
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            } else {
                if indexPath.section == 3 {
                    cell.cancelButton.rx.tap
                        .map { Reactor.Action.recentSearchListDeleteButtonTapped(indexPath: indexPath)}
                        .bind(to: reactor.action)
                        .disposed(by: cell.disposeBag)
                } else {
                    cell.cancelButton.rx.tap
                        .map { Reactor.Action.categoryDelteButtonTapped(indexPath: indexPath)}
                        .bind(to: reactor.action)
                        .disposed(by: cell.disposeBag)
                }
            }
        }

        if let cell = cell as? SearchCountTitleSectionCell {
            cell.sortedButton.rx.tap
                .withUnretained(self)
                .map({ (owner, _) in
                    Reactor.Action.sortedButtonTapped(controller: owner)
                })
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        if let cell = cell as? HomeCardSectionCell {
            cell.bookmarkButton.rx.tap
                .map { Reactor.Action.bookmarkButtonTapped(indexPath: indexPath)}
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mainView.endEditing(true)
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY + scrollViewHeight >= contentHeight {
            loadNextPage.onNext(())
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapped.onNext(indexPath)
    }
}
