//
//  CommentDetailController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class CommentDetailController: BaseViewController, View {

    typealias Reactor = CommentDetailReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    var mainView = CommentDetailView()

    private var sections: [any Sectionable] = []

    private var cellTapped: PublishSubject<IndexPath> = .init()
}

// MARK: - Life Cycle
extension CommentDetailController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension CommentDetailController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(
            DetailCommentImageCell.self,
            forCellWithReuseIdentifier: DetailCommentImageCell.identifiers
        )

        mainView.contentCollectionView.register(
            SpacingSectionCell.self,
            forCellWithReuseIdentifier: SpacingSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            CommentDetailContentSectionCell.self,
            forCellWithReuseIdentifier: CommentDetailContentSectionCell.identifiers
        )

        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension CommentDetailController {
    func bind(reactor: Reactor) {

        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        cellTapped
            .withUnretained(self)
            .map { (owner, indexPath) in
                Reactor.Action.imageCellTapped(controller: owner, row: indexPath.row)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.likeButton.rx.tap
            .map { Reactor.Action.likeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.profileView.dateLabel.text = state.commentData.date
                owner.mainView.profileView.nickNameLabel.text = state.commentData.nickName
                owner.mainView.profileView.profileImageView.setPPImage(path: state.commentData.profileImagePath)
                owner.mainView.likeButtonTitleLabel.setLineHeightText(text: "도움돼요 \(state.commentData.likeCount)", font: .korFont(style: .medium, size: 13))
                if state.commentData.isLike {
                    owner.mainView.likeButtonImageView.image = UIImage(named: "icon_like_blue")
                    owner.mainView.likeButtonTitleLabel.textColor = .blu500
                } else {
                    owner.mainView.likeButtonImageView.image = UIImage(named: "icon_like_gray")
                    owner.mainView.likeButtonTitleLabel.textColor = .g400
                }
                owner.sections = state.sections
                owner.mainView.contentCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CommentDetailController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        if let _  = collectionView.cellForItem(at: indexPath) as? DetailCommentImageCell {
            cellTapped.onNext(indexPath)
        }
    }
}
// MARK: - PanModalPresentable
extension CommentDetailController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return mainView.contentCollectionView
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(UIScreen.main.bounds.height - 68)
    }

    var shortFormHeight: PanModalHeight {
        return .contentHeight(UIScreen.main.bounds.height - 68)
    }

    var showDragIndicator: Bool {
        return false
    }
    var cornerRadius: CGFloat {
        return 20
    }
}
