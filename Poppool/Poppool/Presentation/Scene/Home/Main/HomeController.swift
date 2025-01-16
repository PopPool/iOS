//
//  HomeController.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/28/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class HomeController: BaseViewController, View {
    
    typealias Reactor = HomeReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = HomeView()
    
    let homeHeaderView: HomeHeaderView = {
        let view = HomeHeaderView()
        return view
    }()
    
    private let headerBackgroundView: UIView = UIView()
    let backGroundblurEffect = UIBlurEffect(style: .regular)
    lazy var backGroundblurView = UIVisualEffectView(effect: backGroundblurEffect)
    
    private var sections: [any Sectionable] = []
}

// MARK: - Life Cycle
extension HomeController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let cell = mainView.contentCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageBannerSectionCell {
            cell.stopAutoScroll()
        }
    }
}

// MARK: - SetUp
private extension HomeController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            layout.register(SectionBackGroundDecorationView.self, forDecorationViewOfKind: "BackgroundView")
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        
        mainView.contentCollectionView.register(
            ImageBannerSectionCell.self,
            forCellWithReuseIdentifier: ImageBannerSectionCell.identifiers
        )
        
        mainView.contentCollectionView.register(
            SpacingSectionCell.self,
            forCellWithReuseIdentifier: SpacingSectionCell.identifiers
        )
        
        mainView.contentCollectionView.register(
            HomeTitleSectionCell.self,
            forCellWithReuseIdentifier: HomeTitleSectionCell.identifiers
        )
        
        mainView.contentCollectionView.register(
            HomeCardSectionCell.self,
            forCellWithReuseIdentifier: HomeCardSectionCell.identifiers
        )
        
        mainView.contentCollectionView.register(
            HomePopularCardSectionCell.self,
            forCellWithReuseIdentifier: HomePopularCardSectionCell.identifiers
        )
        
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(homeHeaderView)
        homeHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(7)
            make.leading.trailing.equalToSuperview()
        }
        
        headerBackgroundView.addSubview(backGroundblurView)
        backGroundblurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backGroundblurView.isUserInteractionEnabled = false
        backGroundblurView.isHidden = true
        
        view.addSubview(headerBackgroundView)
        headerBackgroundView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(homeHeaderView.snp.bottom).offset(7)
        }

        
        view.bringSubviewToFront(homeHeaderView)
    }
}

// MARK: - Methods
extension HomeController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        homeHeaderView.searchBarButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.searchButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                if state.isReloadView { owner.mainView.contentCollectionView.reloadData() }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        
        if let cell = cell as? ImageBannerSectionCell {
            cell.bannerTapped
                .withUnretained(self)
                .map({ (owner, row) in
                    Reactor.Action.bannerCellTapped(controller: owner, row: row)
                })
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            cell.imageSection.currentPage
                .distinctUntilChanged()
                .withUnretained(self)
                .debounce(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
                .map({ (owner, row) in
                    Reactor.Action.changeIndicatorColor(controller: owner, row: row)
                })
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        if let cell = cell as? HomeTitleSectionCell {
            cell.detailButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    return Reactor.Action.detailButtonTapped(controller: owner, indexPath: indexPath)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        
        if let cell = cell as? HomeCardSectionCell {
            cell.bookmarkButton.rx.tap
                .map { Reactor.Action.bookMarkButtonTapped(indexPath: indexPath)}
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cell = mainView.contentCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageBannerSectionCell {

            if scrollView.contentOffset.y <= (307 - headerBackgroundView.frame.maxY) {
                cell.startAutoScroll()
                backGroundblurView.isHidden = true
            } else {
                cell.stopAutoScroll()
                systemStatusBarIsDark.accept(true)
                backGroundblurView.isHidden = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reactor?.action.onNext(.collectionViewCellTapped(controller: self, indexPath: indexPath))
    }
}
