//
//  NormalCommentEditController.swift
//  Poppool
//
//  Created by SeoJunYoung on 2/1/25.
//

import UIKit

import ReactorKit
import RxCocoa
import RxKeyboard
import RxSwift
import SnapKit

final class NormalCommentEditController: BaseViewController, View {

    typealias Reactor = NormalCommentEditReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var keyBoardDisposeBag = DisposeBag()

    private var mainView = NormalCommentEditView()

    private var sections: [any Sectionable] = []
}

// MARK: - Life Cycle
extension NormalCommentEditController {
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
private extension NormalCommentEditController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(
            AddCommentTitleSectionCell.self,
            forCellWithReuseIdentifier: AddCommentTitleSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            SpacingSectionCell.self,
            forCellWithReuseIdentifier: SpacingSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            AddCommentDescriptionSectionCell.self,
            forCellWithReuseIdentifier: AddCommentDescriptionSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            AddCommentImageSectionCell.self,
            forCellWithReuseIdentifier: AddCommentImageSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            AddCommentSectionCell.self,
            forCellWithReuseIdentifier: AddCommentSectionCell.identifiers
        )
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension NormalCommentEditController {
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

        // RxKeyboard로 키보드 높이 감지
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardHeight in
                guard let self = self else { return }
                if keyboardHeight == 0 {
                    self.mainView.contentCollectionView.setContentOffset(.init(x: 0, y: 0), animated: true)
                    UIView.animate(withDuration: 0.3) {
                        self.mainView.transform = .identity
                    }

                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.mainView.transform = .init(translationX: 0, y: -100)
                    }
                }
            })
            .disposed(by: keyBoardDisposeBag)

        mainView.saveButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                owner.mainView.endEditing(true)
                return Reactor.Action.saveButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                if state.isSaving {
                    owner.mainView.saveButton.isEnabled = false
                } else {
                    let text = state.text ?? ""
                    if (10...500).contains(text.count) {
                        owner.mainView.saveButton.isEnabled = true
                    } else {
                        owner.mainView.saveButton.isEnabled = false
                    }
                }
                owner.sections = state.sections
                if state.isReloadView { owner.mainView.contentCollectionView.reloadData() }

            }
            .disposed(by: disposeBag)

        reactor.state
            .take(1)
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                if state.isReloadView { owner.mainView.contentCollectionView.reloadData() }

            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension NormalCommentEditController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        if let cell = cell as? AddCommentImageSectionCell {
            cell.deleteButton.rx.tap
                .map { Reactor.Action.imageDeleteButtonTapped(indexPath: indexPath) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        if let cell = cell as? AddCommentSectionCell {
            cell.commentTextView.rx.didChange
                .withUnretained(cell)
                .map({ (cell, _) in
                    Reactor.Action.inputComment(text: cell.commentTextView.text)
                })
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 5 && indexPath.row == 0 {
            reactor?.action.onNext(.photoAddButtonTapped(controller: self))
        }
        view.endEditing(true)
    }
}
