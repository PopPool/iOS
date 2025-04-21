//
//  SignUpStep3Controller.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit

final class SignUpStep3Controller: BaseViewController, View {

    typealias Reactor = SignUpStep3Reactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    var mainView = SignUpStep3View()

    private var sections: [any Sectionable] = []

    private let selectedTag: PublishSubject<IndexPath> = .init()
}

// MARK: - Life Cycle
extension SignUpStep3Controller {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        if let layout = reactor?.compositionalLayout {
            mainView.categoryCollectionView.collectionViewLayout = layout
        }
        mainView.categoryCollectionView.delegate = self
        mainView.categoryCollectionView.dataSource = self
        mainView.categoryCollectionView.register(
            TagSectionCell.self,
            forCellWithReuseIdentifier: TagSectionCell.identifiers
        )
    }
}

// MARK: - SetUp
private extension SignUpStep3Controller {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SignUpStep3Controller {
    func bind(reactor: Reactor) {

        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        selectedTag
            .map { Reactor.Action.selectedTag(indexPath: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                owner.mainView.completeButton.isEnabled = !state.selectedCategory.isEmpty
                owner.mainView.categoryCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SignUpStep3Controller: UICollectionViewDelegate, UICollectionViewDataSource {
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
        selectedTag.onNext(indexPath)
    }
}
