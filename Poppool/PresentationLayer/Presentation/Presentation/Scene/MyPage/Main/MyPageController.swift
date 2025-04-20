//
//  MyPageController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/30/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class MyPageController: BaseViewController, View {

    typealias Reactor = MyPageReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = MyPageView()

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .w100
        view.alpha = 0
        return view
    }()

    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_gear_white"), for: .normal)
        button.tintColor = .g1000
        return button
    }()

    private var sections: [any Sectionable] = []
    private var commentCellTapped: PublishSubject<Int> = .init()
    private var listCellTapped: PublishSubject<String?> = .init()

    private var isBrightImage: Bool = false

    private var scrollAlpha: CGFloat = 0

}

// MARK: - Life Cycle
extension MyPageController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - SetUp
private extension MyPageController {
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
            MyPageProfileSectionCell.self,
            forCellWithReuseIdentifier: MyPageProfileSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            MyPageMyCommentTitleSectionCell.self,
            forCellWithReuseIdentifier: MyPageMyCommentTitleSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            MyPageCommentSectionCell.self,
            forCellWithReuseIdentifier: MyPageCommentSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            MyPageListSectionCell.self,
            forCellWithReuseIdentifier: MyPageListSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            MyPageLogoutSectionCell.self,
            forCellWithReuseIdentifier: MyPageLogoutSectionCell.identifiers
        )
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }

        view.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.trailing.equalTo(headerView.snp.trailing).inset(16)
            make.bottom.equalTo(headerView.snp.bottom).inset(6)
            make.size.equalTo(32)
        }
    }
}

// MARK: - Methods
extension MyPageController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        commentCellTapped
            .withUnretained(self)
            .map { (owner, index) in
                Reactor.Action.commentCellTapped(controller: owner, row: index)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        listCellTapped
            .withUnretained(self)
            .map { (owner, title) in
                Reactor.Action.listCellTapped(controller: owner, title: title)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        settingButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.settingButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.settingButton.isHidden = !state.isLogin
                owner.sections = state.sections
                owner.mainView.contentCollectionView.reloadData()

            }
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                state.backgroundImageViewPath.isBrightImagePath { isBright in
                    owner.isBrightImage = isBright
                    UIView.animate(withDuration: 0.3) {
                        if isBright {
                            owner.settingButton.tintColor = .g1000
                            owner.systemStatusBarIsDark.accept(true)
                        } else {
                            if owner.scrollAlpha > 0.5 {
                                owner.settingButton.tintColor = .g1000
                                owner.systemStatusBarIsDark.accept(true)
                            } else {
                                owner.settingButton.tintColor = .w100
                                owner.systemStatusBarIsDark.accept(false)
                            }

                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MyPageController: UICollectionViewDelegate, UICollectionViewDataSource {
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

        if let cell = cell as? MyPageProfileSectionCell {
            let originHeight = 162 + 49 + 44 + view.safeAreaInsets.top
            cell.updateHeight(height: originHeight)
            cell.updateContentTopInset(inset: 44 + view.safeAreaInsets.top)
            cell.loginButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.loginButtonTapped(controller: owner)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        if let cell = cell as? MyPageMyCommentTitleSectionCell {
            cell.button.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    Reactor.Action.commentButtonTapped(controller: owner)
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        if let cell = cell as? MyPageLogoutSectionCell {
            cell.logoutButton.rx.tap
                .map { Reactor.Action.logoutButtonTapped }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MyPageCommentSectionCell {
            commentCellTapped.onNext(indexPath.row)
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? MyPageListSectionCell {
            let title = cell.titleLabel.text
            listCellTapped.onNext(title)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cell = mainView.contentCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? MyPageProfileSectionCell {
            let contentOffsetY = scrollView.contentOffset.y
            let originHeight = 44 + view.safeAreaInsets.top
            let alpha = max(0, contentOffsetY / 162)
            if contentOffsetY > 0 {
                cell.updateContentTopInset(inset: (contentOffsetY * 2) + originHeight)
            } else {
                cell.updateContentTopInset(inset: originHeight)
            }
            cell.updateAlpha(alpha: alpha)
            scrollAlpha = alpha
            if alpha < 0.5 {
                systemStatusBarIsDark.accept(isBrightImage)
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self = self else { return }
                    if isBrightImage {
                        self.settingButton.tintColor = .g1000
                    } else {
                        self.settingButton.tintColor = .w100
                    }
                }
            } else {
                systemStatusBarIsDark.accept(true)
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.settingButton.tintColor = .g1000
                }
            }
            headerView.alpha = alpha
        }
    }
}
