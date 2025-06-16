import UIKit

import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class BlockUserManageController: BaseViewController, View {

    typealias Reactor = BlockUserManageReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = BlockUserManageView()

    private var sections: [any Sectionable] = []
}

// MARK: - Life Cycle
extension BlockUserManageController {
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
private extension BlockUserManageController {
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
            BlockUserListSectionCell.self,
            forCellWithReuseIdentifier: BlockUserListSectionCell.identifiers
        )

        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension BlockUserManageController {
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
                owner.mainView.emptyLabel.isHidden = !state.isEmptyList
                owner.mainView.contentCollectionView.isHidden = state.isEmptyList
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension BlockUserManageController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        if let cell = cell as? BlockUserListSectionCell {
            cell.blockButton.rx.tap
                .map { Reactor.Action.blockButtonTapped(row: indexPath.row) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        return cell
    }
}
