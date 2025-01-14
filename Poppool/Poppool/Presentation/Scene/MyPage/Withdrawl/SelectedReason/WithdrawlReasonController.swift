//
//  WithdrawlReasonController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/7/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import RxKeyboard
import RxGesture

final class WithdrawlReasonController: BaseViewController, View {
    
    typealias Reactor = WithdrawlReasonReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = WithdrawlReasonView()
    
    private var sections: [any Sectionable] = []
}

// MARK: - Life Cycle
extension WithdrawlReasonController {
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
private extension WithdrawlReasonController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(
            WithdrawlCheckSectionCell.self,
            forCellWithReuseIdentifier: WithdrawlCheckSectionCell.identifiers
        )        
        mainView.contentCollectionView.register(
            SpacingSectionCell.self,
            forCellWithReuseIdentifier: SpacingSectionCell.identifiers
        )
        
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension WithdrawlReasonController {
    func bind(reactor: Reactor) {
        view.rx.tapGesture()
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
            
        RxKeyboard.instance.visibleHeight
            .drive { [weak self] height in
                if height > 0 {
                    UIView.animate(withDuration: 0.3) {
                        self?.view.transform = CGAffineTransform(translationX: 0, y: -height)
                    }
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self?.view.transform = .identity
                    }
                }

            }
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
        
        mainView.checkButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.checkButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.skipButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.skipButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.checkButton.isEnabled = state.buttonIsEnabled
                if state.isReloadView {
                    owner.sections = state.sections
                    owner.mainView.contentCollectionView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension WithdrawlReasonController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        
        if let cell = cell as? WithdrawlCheckSectionCell {
            cell.cellButton.rx.tap
                .map { Reactor.Action.cellTapped(row: indexPath.row) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        
            cell.textView.rx.text
                .map { Reactor.Action.etcTextInput(text: $0)}
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)

        }
        return cell
    }
}
