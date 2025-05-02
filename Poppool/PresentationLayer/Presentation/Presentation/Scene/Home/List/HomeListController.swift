import UIKit

import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class HomeListController: BaseViewController, View {

    typealias Reactor = HomeListReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = HomeListView()

    private var sections: [any Sectionable] = []

    private let pageChange: PublishSubject<Void> = .init()

    private let cellTapped: PublishSubject<Int> = .init()
}

// MARK: - Life Cycle
extension HomeListController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - SetUp
private extension HomeListController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self

        mainView.contentCollectionView.register(
            HomeCardSectionCell.self,
            forCellWithReuseIdentifier: HomeCardSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            SpacingSectionCell.self,
            forCellWithReuseIdentifier: SpacingSectionCell.identifiers
        )
    }
}

// MARK: - Methods
extension HomeListController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.headerView.backButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.backButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        pageChange
            .throttle(.milliseconds(1000), scheduler: MainScheduler.asyncInstance)
            .map { Reactor.Action.changePage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        cellTapped
            .withUnretained(self)
            .map { (owner, row) in
                Reactor.Action.cellTapped(controller: owner, row: row)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.headerView.headerLabel.text = state.popUpType.title
                owner.sections = state.sections
                if state.isReloadView { owner.mainView.contentCollectionView.reloadData() }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeListController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        guard let reactor = reactor else { return cell }
        if let cell = cell as? HomeCardSectionCell {
            cell.bookmarkButton.rx.tap
                .map { Reactor.Action.bookMarkButtonTapped(indexPath: indexPath)}
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY + scrollViewHeight >= contentHeight {
            pageChange.onNext(())
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 { cellTapped.onNext(indexPath.row)}
    }
}
