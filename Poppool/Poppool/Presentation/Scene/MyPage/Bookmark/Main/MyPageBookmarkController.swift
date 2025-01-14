//
//  MyPageBookmarkController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class MyPageBookmarkController: BaseViewController, View {
    
    typealias Reactor = MyPageBookmarkReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = MyPageBookmarkView()
    
    private var sections: [any Sectionable] = []
    
    private var cellTapped: PublishSubject<Int> = .init()
}

// MARK: - Life Cycle
extension MyPageBookmarkController {
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
private extension MyPageBookmarkController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(
            SpacingSectionCell.self,
            forCellWithReuseIdentifier: SpacingSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            DetailSimilarSectionCell.self,
            forCellWithReuseIdentifier: DetailSimilarSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            ListCountButtonSectionCell.self,
            forCellWithReuseIdentifier: ListCountButtonSectionCell.identifiers
        )        
        mainView.contentCollectionView.register(
            PopUpCardSectionCell.self,
            forCellWithReuseIdentifier: PopUpCardSectionCell.identifiers
        )
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension MyPageBookmarkController {
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
        
        mainView.emptyButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.emptyButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                if state.isReloadView { owner.mainView.contentCollectionView.reloadData() }
                owner.mainView.contentCollectionView.isHidden = state.isEmptyCase
                owner.mainView.emptyLabel.isHidden = !state.isEmptyCase
                owner.mainView.emptyButton.isHidden = !state.isEmptyCase
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MyPageBookmarkController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        if let cell = cell as? ListCountButtonSectionCell {
            cell.dropdownButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.dropDownButtonTapped(controller: owner)
                }
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
            reactor?.action.onNext(.changePage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 4 { cellTapped.onNext(indexPath.row) }
    }
}
