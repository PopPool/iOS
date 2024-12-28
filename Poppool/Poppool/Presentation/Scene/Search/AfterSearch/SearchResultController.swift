//
//  SearchResultController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/7/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class SearchResultController: BaseViewController, View {
    
    typealias Reactor = SearchResultReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = SearchResultView()
    private var sections: [any Sectionable] = []
    private let cellTapped: PublishSubject<IndexPath> = .init()
}

// MARK: - Life Cycle
extension SearchResultController {
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
private extension SearchResultController {
    func setUp() {
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
            SearchResultCountSectionCell.self,
            forCellWithReuseIdentifier: SearchResultCountSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            HomeCardSectionCell.self,
            forCellWithReuseIdentifier: HomeCardSectionCell.identifiers
        )
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SearchResultController {
    func bind(reactor: Reactor) {
        
        cellTapped
            .withUnretained(self)
            .map({ (owner, indexPath) in
                Reactor.Action.cellTapped(controller: owner, indexPath: indexPath)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                if state.isEmptyResult {
                    owner.mainView.emptyLabel.isHidden = false
                    owner.mainView.contentCollectionView.isHidden = true
                } else {
                    owner.mainView.emptyLabel.isHidden = true
                    owner.mainView.contentCollectionView.isHidden = false
                    owner.sections = state.sections
                    owner.mainView.contentCollectionView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchResultController: UICollectionViewDelegate, UICollectionViewDataSource {
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
                .map { Reactor.Action.bookmarkButtonTapped(indexPath: indexPath)}
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapped.onNext(indexPath)
    }
}
