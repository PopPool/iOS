import UIKit

import DesignSystem

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class CategoryEditModalController: BaseViewController, View {

    typealias Reactor = CategoryEditModalReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = CategoryEditModalView()

    private var sections: [any Sectionable] = []
}

// MARK: - Life Cycle
extension CategoryEditModalController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension CategoryEditModalController {
    func setUp() {
        if let layout = reactor?.compositionalLayout {
            mainView.contentCollectionView.collectionViewLayout = layout
        }
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.register(TagSectionCell.self, forCellWithReuseIdentifier: TagSectionCell.identifiers)

        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension CategoryEditModalController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.xmarkButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.xmarkButtonTapped(controller: owner)
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
                owner.mainView.contentCollectionView.reloadData()
                owner.mainView.saveButton.isEnabled = state.saveButtonIsEnable
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CategoryEditModalController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        return sections[indexPath.section].getCell(collectionView: collectionView, indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reactor?.action.onNext(.cellTapped(row: indexPath.row))
    }
}

// MARK: - PanModalPresentable
extension CategoryEditModalController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(360)
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(360)
    }
    var showDragIndicator: Bool {
        return false
    }
    var cornerRadius: CGFloat {
        return 20
    }
}
