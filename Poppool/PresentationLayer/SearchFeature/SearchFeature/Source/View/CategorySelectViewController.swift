import UIKit

import DesignSystem

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class CategorySelectViewController: BaseViewController, View {

    typealias Reactor = CategorySelectReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = CategorySelectView()
}

// MARK: - Life Cycle
extension CategorySelectViewController {
    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Methods
extension CategorySelectViewController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.categoryItems }
            .distinctUntilChanged()
            .bind(to: mainView.collectionView.rx.items(
                cellIdentifier: TagCollectionViewCell.identifiers,
                cellType: TagCollectionViewCell.self
            )) { index, input, cell in
                cell.injection(with: input)
            }
            .disposed(by: disposeBag)

        mainView.collectionView.rx.itemSelected
            .withLatestFrom(
                reactor.state.map { Array($0.categoryItems) },
                resultSelector: { indexPath, items in items[indexPath.item] }
            )
            .compactMap { $0.id }
            .map { Reactor.Action.cellTapped(categoryID: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.closeButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in owner.dismiss(animated: true) }
            .disposed(by: disposeBag)


        mainView.resetButton.rx.tap
            .withUnretained(self)
            .do { (owner, _) in owner.dismiss(animated: true) }
            .map { (owner, _) in Reactor.Action.resetButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.saveButton.rx.tap
            .withUnretained(self)
            .do { (owner, _) in owner.dismiss(animated: true) }
            .map { (owner, _) in Reactor.Action.saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)


        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.saveButton.isEnabled = state.saveButtonIsEnable
                // owner.mainView.collectionView.reloadItems
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension CategorySelectViewController: PanModalPresentable {
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
