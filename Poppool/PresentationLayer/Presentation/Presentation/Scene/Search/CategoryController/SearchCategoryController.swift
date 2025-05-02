import UIKit

import DesignSystem

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class SearchCategoryController: BaseViewController, View {

    typealias Reactor = SearchCategoryReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = SearchCategoryView()
    private var sections: [any Sectionable] = []
    private let cellTapped: PublishSubject<IndexPath> = .init()
}

// MARK: - Life Cycle
extension SearchCategoryController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension SearchCategoryController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(
            TagSectionCell.self,
            forCellWithReuseIdentifier: TagSectionCell.identifiers
        )
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SearchCategoryController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        cellTapped
            .map { Reactor.Action.cellTapped(indexPath: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.resetButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.resetButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.closeButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.closeButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.saveButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.saveButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.sections = state.sections
                owner.mainView.saveButton.isEnabled = state.saveButtonIsEnable
                owner.mainView.contentCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchCategoryController: UICollectionViewDelegate, UICollectionViewDataSource {
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapped.onNext(indexPath)
    }
}
// MARK: - PanModalPresentable
extension SearchCategoryController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    var longFormHeight: PanModalHeight {
        return .intrinsicHeight
    }
    var shortFormHeight: PanModalHeight {
        return .intrinsicHeight
    }
    var showDragIndicator: Bool {
        return false
    }
    var cornerRadius: CGFloat {
        return 20
    }
}
