//
//  MyPageNoticeController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/13/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class MyPageNoticeController: BaseViewController, View {
    
    typealias Reactor = MyPageNoticeReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = MyPageNoticeView()
    
    private var sections: [any Sectionable] = []
    
    private var cellTapped: PublishSubject<Int> = .init()
}

// MARK: - Life Cycle
extension MyPageNoticeController {
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
private extension MyPageNoticeController {
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
            CommentListTitleSectionCell.self,
            forCellWithReuseIdentifier: CommentListTitleSectionCell.identifiers
        )        
        mainView.contentCollectionView.register(
            NoticeListSectionCell.self,
            forCellWithReuseIdentifier: NoticeListSectionCell.identifiers
        )
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension MyPageNoticeController {
    func bind(reactor: Reactor) {
        
        mainView.headerView.backButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.backButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        cellTapped
            .withUnretained(self)
            .map { (owner, row) in
                Reactor.Action.listCellTapped(controller: owner, row: row)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                owner.mainView.contentCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MyPageNoticeController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 3 { cellTapped.onNext(indexPath.row) }
    }
}
