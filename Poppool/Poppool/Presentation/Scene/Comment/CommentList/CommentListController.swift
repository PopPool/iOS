//
//  CommentListController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class CommentListController: BaseViewController, View {

    typealias Reactor = CommentListReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = CommentListView()
    private var sections: [any Sectionable] = []
    private let scrollObserver: PublishSubject<Void> = .init()
}

// MARK: - Life Cycle
extension CommentListController {
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
private extension CommentListController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(DetailCommentSectionCell.self, forCellWithReuseIdentifier: DetailCommentSectionCell.identifiers)
        mainView.contentCollectionView.register(CommentListTitleSectionCell.self, forCellWithReuseIdentifier: CommentListTitleSectionCell.identifiers)
        mainView.contentCollectionView.register(SpacingSectionCell.self, forCellWithReuseIdentifier: SpacingSectionCell.identifiers)
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension CommentListController {
    func bind(reactor: Reactor) {

        scrollObserver
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Reactor.Action.scrollDidEndPoint }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

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

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                if state.isReloadView { owner.mainView.contentCollectionView.reloadData()}
            }
            .disposed(by: disposeBag)

    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CommentListController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        if let cell = cell as? DetailCommentSectionCell {
            cell.imageCollectionView.rx.itemSelected
                .withUnretained(self)
                .map { (owner, cellIndexPath) in
                    Reactor.Action.imageCellTapped(controller: owner, commentRow: indexPath.row, imageRow: cellIndexPath.row)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)

            cell.profileView.button.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.profileButtonTapped(controller: owner, row: indexPath.row)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)

            cell.totalViewButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.detailButtonTapped(controller: owner, row: indexPath.row)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)

            cell.likeButton.rx.tap
                .map { Reactor.Action.likeButtonTapped(row: indexPath.row) }
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
            scrollObserver.onNext(())
        }
    }
}
