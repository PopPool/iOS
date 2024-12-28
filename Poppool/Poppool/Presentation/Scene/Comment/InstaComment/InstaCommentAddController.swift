//
//  InstaCommentAddController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import SwiftSoup

final class InstaCommentAddController: BaseViewController, View {
    
    typealias Reactor = InstaCommentAddReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = InstaCommentAddView()
    private var sections: [any Sectionable] = []
}

// MARK: - Life Cycle
extension InstaCommentAddController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension InstaCommentAddController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(InstaGuideSectionCell.self, forCellWithReuseIdentifier: InstaGuideSectionCell.identifiers)
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension InstaCommentAddController {
    func bind(reactor: Reactor) {
        
        SceneDelegate.appDidBecomeActive
            .subscribe { _ in
                if let url = UIPasteboard.general.string {
//                    guard let url = URL(string: url) else { return }
//                    self.crawl(url: url)
//                    self.fetchHTML(url: url)
                } else {
                    print("Clipboard is empty or does not contain text")
                }
            }
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.instaButton.rx.tap
            .map { Reactor.Action.instaButtonTapped }
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
extension InstaCommentAddController: UICollectionViewDelegate, UICollectionViewDataSource {
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
}
