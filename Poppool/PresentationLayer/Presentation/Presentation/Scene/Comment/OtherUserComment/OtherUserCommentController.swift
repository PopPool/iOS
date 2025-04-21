//
//  OtherUserCommentController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class OtherUserCommentController: BaseViewController, View {

    typealias Reactor = OtherUserCommentReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = OtherUserCommentView()

    private var sections: [any Sectionable] = []

    private let cellTapped: PublishSubject<Int> = .init()
}

// MARK: - Life Cycle
extension OtherUserCommentController {
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
private extension OtherUserCommentController {
    func setUp() {
        view.addSubview(mainView)
        view.backgroundColor = .g50
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self

        mainView.contentCollectionView.register(
            CommentListTitleSectionCell.self,
            forCellWithReuseIdentifier: CommentListTitleSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            SpacingSectionCell.self,
            forCellWithReuseIdentifier: SpacingSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            MyCommentedPopUpGridSectionCell.self,
            forCellWithReuseIdentifier: MyCommentedPopUpGridSectionCell.identifiers
        )
    }
}

// MARK: - Methods
extension OtherUserCommentController {
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
                owner.sections = state.sections
                if state.isReloadView { owner.mainView.contentCollectionView.reloadData() }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension OtherUserCommentController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        return sections[indexPath.section].getCell(collectionView: collectionView, indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 3 { cellTapped.onNext(indexPath.row) }
    }
}
