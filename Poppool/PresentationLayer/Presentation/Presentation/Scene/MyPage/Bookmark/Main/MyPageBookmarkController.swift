import UIKit

import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class MyPageBookmarkController: BaseViewController, View {

    typealias Reactor = MyPageBookmarkReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = MyPageBookmarkView()

    private var sections: [any Sectionable] = []

    private var cellTapped: PublishSubject<Int> = .init()

    private var currentPageIndex: Int = 0

    private var maxPageIndex: Int = 0

    private var viewType: String?
}

// MARK: - Life Cycle
extension MyPageBookmarkController {
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
private extension MyPageBookmarkController {
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
            DetailSimilarSectionCell.self,
            forCellWithReuseIdentifier: DetailSimilarSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            ListCountButtonSectionCell.self,
            forCellWithReuseIdentifier: ListCountButtonSectionCell.identifiers
        )
        mainView.contentCollectionView.register(
            PopUpCardSectionCell.self,
            forCellWithReuseIdentifier: PopUpCardSectionCell.identifiers
        )
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension MyPageBookmarkController {
    func bind(reactor: Reactor) {
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

        cellTapped
            .withUnretained(self)
            .map { (owner, row) in
                Reactor.Action.cellTapped(controller: owner, row: row)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.emptyButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.emptyButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.countButtonView.dropdownButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.dropDownButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.contentCollectionView.rx.gesture(.swipe(direction: .up))
            .skip(1)
            .withUnretained(self)
            .subscribe { (owner, _) in
                if owner.viewType == "크게보기" {
                    if owner.maxPageIndex - 1 > owner.currentPageIndex {
                        if let currentCell = owner.mainView.contentCollectionView.cellForItem(at: .init(row: owner.currentPageIndex, section: 1)) as? PopUpCardSectionCell,
                           let nextCell = owner.mainView.contentCollectionView.cellForItem(at: .init(row: owner.currentPageIndex + 1, section: 1)) as? PopUpCardSectionCell {
                            currentCell.layer.zPosition = 0
                            nextCell.layer.zPosition = 1
                            UIView.animate(withDuration: 0.3) {
                                currentCell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 0, y: 590)
                                currentCell.contentView.alpha = 0.5
                            } completion: { _ in
                                currentCell.transform = .identity
                                currentCell.layer.zPosition = 0
                                nextCell.layer.zPosition = 0
                                currentCell.contentView.alpha = 1
                            }
                        }
                        owner.currentPageIndex += 1
                        owner.mainView.contentCollectionView.scrollToItem(at: .init(row: owner.currentPageIndex, section: 1), at: .top, animated: true)

                    }
                }
            }
            .disposed(by: disposeBag)

        mainView.contentCollectionView.rx.gesture(.swipe(direction: .down))
            .skip(1)
            .withUnretained(self)
            .subscribe { (owner, _) in
                if owner.viewType == "크게보기" {
                    if owner.currentPageIndex > 0 {
                        owner.currentPageIndex -= 1
                        owner.mainView.contentCollectionView.scrollToItem(at: .init(row: owner.currentPageIndex, section: 1), at: .top, animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                if state.isReloadView { owner.mainView.contentCollectionView.reloadData() }
                owner.mainView.contentCollectionView.isHidden = state.isEmptyCase
                owner.mainView.emptyLabel.isHidden = !state.isEmptyCase
                owner.mainView.emptyButton.isHidden = !state.isEmptyCase
                owner.mainView.countButtonView.buttonTitleLabel.setLineHeightText(text: state.buttonTitle, font: .korFont(style: .regular, size: 13))
                owner.mainView.countButtonView.countLabel.setLineHeightText(text: "총 \(state.count)개", font: .korFont(style: .regular, size: 13))

                if state.buttonTitle != owner.viewType {
                    owner.mainView.contentCollectionView.scrollsToTop = true
                }

                if state.buttonTitle == "크게보기" {
                    owner.mainView.contentCollectionView.isScrollEnabled = false
                    if owner.viewType == "모아서보기" {
                        owner.currentPageIndex = 0
                        owner.mainView.contentCollectionView.scrollToItem(at: .init(row: owner.currentPageIndex, section: 1), at: .top, animated: false)
                    }
                } else {
                    owner.mainView.contentCollectionView.isScrollEnabled = true
                }

                owner.maxPageIndex = Int(state.count)
                owner.viewType = state.buttonTitle
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MyPageBookmarkController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        if let cell = cell as? PopUpCardSectionCell {
            cell.bookMarkButton.rx.tap
                .map { Reactor.Action.bookMarkButtonTapped(row: indexPath.row) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }

        if let cell = cell as? DetailSimilarSectionCell {
            cell.bookMarkButton.rx.tap
                .map { Reactor.Action.bookMarkButtonTapped(row: indexPath.row) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
        }
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY + scrollViewHeight >= contentHeight {
            reactor?.action.onNext(.changePage)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 { cellTapped.onNext(indexPath.row) }
    }

}
