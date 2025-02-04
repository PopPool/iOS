//
//  MyPageTermsController.swift
//  Poppool
//
//  Created by SeoJunYoung on 2/4/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class MyPageTermsController: BaseViewController, View {
    
    typealias Reactor = MyPageTermsReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "약관", font: .KorFont(style: .regular, size: 15))
        return view
    }()
    
    lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self = self else {
                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    ))
                )
            }
            return sections[section].getSection(section: section, env: env)
        }
    }()
    
    private lazy var contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.compositionalLayout)
        view.backgroundColor = .g50
        return view
    }()
    
    private var sections: [any Sectionable] = []
    
    private let cellTapped: PublishSubject<IndexPath> = .init()
}

// MARK: - Life Cycle
extension MyPageTermsController {
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
private extension MyPageTermsController {
    func setUp() {
        view.backgroundColor = .g50
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.trailing.leading.equalTo(view.safeAreaLayoutGuide)
        }
        view.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        contentCollectionView.register(CommentListTitleSectionCell.self, forCellWithReuseIdentifier: CommentListTitleSectionCell.identifiers)
        contentCollectionView.register(MyPageListSectionCell.self, forCellWithReuseIdentifier: MyPageListSectionCell.identifiers)
        contentCollectionView.register(SpacingSectionCell.self, forCellWithReuseIdentifier: SpacingSectionCell.identifiers)
    }
}

// MARK: - Methods
extension MyPageTermsController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.backButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.backButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        cellTapped
            .withUnretained(self)
            .map { (owner, indexPath) in
                Reactor.Action.cellTapped(indexPath: indexPath, controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                owner.contentCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MyPageTermsController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapped.onNext(indexPath)
    }
}
