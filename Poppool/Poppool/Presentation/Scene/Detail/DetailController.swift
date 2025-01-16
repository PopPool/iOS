//
//  DetailController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/9/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class DetailController: BaseViewController, View {
    
    typealias Reactor = DetailReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = DetailView()
    
    private let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.backButton.tintColor = .w100
        return view
    }()
    
    private var sections: [any Sectionable] = []
    
    private var isBrightImage: Bool = false
    
    private let headerBackgroundView: UIView = UIView()
    let backGroundblurEffect = UIBlurEffect(style: .regular)
    lazy var backGroundblurView = UIVisualEffectView(effect: backGroundblurEffect)
}

// MARK: - Life Cycle
extension DetailController {
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
private extension DetailController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(ImageBannerSectionCell.self, forCellWithReuseIdentifier: ImageBannerSectionCell.identifiers)
        mainView.contentCollectionView.register(SpacingSectionCell.self, forCellWithReuseIdentifier: SpacingSectionCell.identifiers)
        mainView.contentCollectionView.register(DetailTitleSectionCell.self, forCellWithReuseIdentifier: DetailTitleSectionCell.identifiers)
        mainView.contentCollectionView.register(DetailContentSectionCell.self, forCellWithReuseIdentifier: DetailContentSectionCell.identifiers)
        mainView.contentCollectionView.register(DetailInfoSectionCell.self, forCellWithReuseIdentifier: DetailInfoSectionCell.identifiers)
        mainView.contentCollectionView.register(DetailCommentTitleSectionCell.self, forCellWithReuseIdentifier: DetailCommentTitleSectionCell.identifiers)
        mainView.contentCollectionView.register(DetailCommentSectionCell.self, forCellWithReuseIdentifier: DetailCommentSectionCell.identifiers)
        mainView.contentCollectionView.register(SearchTitleSectionCell.self, forCellWithReuseIdentifier: SearchTitleSectionCell.identifiers)
        mainView.contentCollectionView.register(DetailSimilarSectionCell.self, forCellWithReuseIdentifier: DetailSimilarSectionCell.identifiers)
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        headerBackgroundView.addSubview(backGroundblurView)
        backGroundblurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backGroundblurView.isUserInteractionEnabled = false
        
        view.addSubview(headerBackgroundView)
        headerBackgroundView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(headerView.snp.bottom).offset(7)
        }
        headerBackgroundView.isHidden = true
        
        view.bringSubviewToFront(headerView)
    }
}

// MARK: - Methods
extension DetailController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.commentPostButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.commentButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.backButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.backButtonTapped(controller: owner)
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
        
        reactor.state
            .withUnretained(self)
            .take(2)
            .subscribe { (owner, state) in
                state.barkGroundImagePath.isBrightImagePath { [weak owner] isBright in
                    owner?.statusBarIsDarkMode = isBright
                    owner?.isBrightImage = isBright
                    if isBright {
                        owner?.headerView.backButton.tintColor = .g1000
                    } else {
                        owner?.headerView.backButton.tintColor = .w100
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension DetailController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        
        if let cell = cell as? DetailTitleSectionCell {
            cell.bookMarkButton.rx.tap
                .map { Reactor.Action.bookMarkButtonTapped }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            cell.sharedButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.sharedButtonTapped(controller: owner)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        
        if let cell = cell as? DetailInfoSectionCell {
            cell.copyButton.rx.tap
                .map { Reactor.Action.copyButtonTapped }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            cell.mapButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.addressButtonTapped(controller: owner)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        if let cell = cell as? DetailContentSectionCell {
            cell.dropDownButton.rx.tap
                .withUnretained(collectionView)
                .subscribe { (collectionView, _) in
                    cell.isOpen.toggle()
                    if cell.isOpen {
                        cell.buttonTitleLabel.setLineHeightText(text: "닫기", font: .KorFont(style: .medium, size: 13))
                        cell.contentLabel.numberOfLines = 0
                        cell.buttonImageView.image = UIImage(named: "icon_dropdown_top_gray")
                    } else {
                        cell.contentLabel.numberOfLines = 3
                        cell.buttonTitleLabel.setLineHeightText(text: "더보기", font: .KorFont(style: .medium, size: 13))
                        cell.buttonImageView.image = UIImage(named: "icon_dropdown_bottom_gray")
                    }
                    collectionView.reloadData()
                }
                .disposed(by: cell.disposeBag)
        }
        
        if let cell = cell as? DetailCommentTitleSectionCell {
            cell.totalViewButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.commentTotalViewButtonTapped(controller: owner)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        
        if let cell = cell as? DetailCommentSectionCell {
            cell.imageCollectionView.rx.itemSelected
                .withUnretained(self)
                .map { (owner, cellIndexPath) in
                    Reactor.Action.commentImageTapped(controller: owner, cellRow: indexPath.row, ImageRow: cellIndexPath.row)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            cell.profileView.button.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.commentMenuButtonTapped(controller: owner, indexPath: indexPath)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            cell.totalViewButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.commentDetailButtonTapped(controller: owner, indexPath: indexPath)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            cell.likeButton.rx.tap
                .map { Reactor.Action.commentLikeButtonTapped(indexPath: indexPath) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            cell.loginButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.loginButtonTapped(controller: owner)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 16 {
            reactor?.action.onNext(.similarSectionTapped(controller: self, indexPath: indexPath))
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 241 {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.headerBackgroundView.isHidden = true
            }
            
            if isBrightImage {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.statusBarIsDarkMode = true
                    self?.headerView.backButton.tintColor = .g1000
                }

            } else {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.statusBarIsDarkMode = false
                    self?.headerView.backButton.tintColor = .w100
                }
            }
        } else {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.statusBarIsDarkMode = true
                self?.headerView.backButton.tintColor = .g1000
                self?.headerBackgroundView.isHidden = false
            }
        }
    }
}
