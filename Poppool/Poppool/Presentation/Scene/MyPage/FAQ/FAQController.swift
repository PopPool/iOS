//
//  FAQController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/13/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class FAQController: BaseViewController, View {
    
    typealias Reactor = FAQReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = FAQView()
    private var sections: [any Sectionable] = []
}

// MARK: - Life Cycle
extension FAQController {
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
private extension FAQController {
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
            MyPageMyCommentTitleSectionCell.self,
            forCellWithReuseIdentifier: MyPageMyCommentTitleSectionCell.identifiers
        )        
        mainView.contentCollectionView.register(
            MyPageListSectionCell.self,
            forCellWithReuseIdentifier: MyPageListSectionCell.identifiers
        )        
        mainView.contentCollectionView.register(
            FAQDropdownSectionCell.self,
            forCellWithReuseIdentifier: FAQDropdownSectionCell.identifiers
        )
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension FAQController {
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
extension FAQController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        if let cell = cell as? FAQDropdownSectionCell {
            cell.listContentButton.rx.tap
                .map { Reactor.Action.dropButtonTapped(row: indexPath.row)}
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        return cell
    }
}
