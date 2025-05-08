import UIKit

import DesignSystem

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
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }

    private func bindAction(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.closeButton.rx.tap
            .map { Reactor.Action.closeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.resetButton.rx.tap
            .map { Reactor.Action.resetButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.saveButton.rx.tap
            .map { Reactor.Action.saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.collectionView.rx.itemSelected
            .map(Reactor.Action.categoryTagButtonTapped)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindState(reactor: Reactor) {
        reactor.pulse(\.$dismiss)
            .withUnretained(self)
            .subscribe { (owner, _) in owner.dismiss(animated: true) }
            .disposed(by: disposeBag)

        reactor.state.distinctUntilChanged(\.categoryItems)
            .map(\.categoryItems)
            .bind(to: mainView.collectionView.rx.items(
                cellIdentifier: TagCollectionViewCell.identifiers,
                cellType: TagCollectionViewCell.self
            )) { _, item, cell in cell.injection(with: item) }
            .disposed(by: disposeBag)

        reactor.state.distinctUntilChanged(\.saveButtonIsEnable)
            .withUnretained(self)
            .subscribe { (owner, state) in owner.mainView.saveButton.isEnabled = state.saveButtonIsEnable }
            .disposed(by: disposeBag)
    }
}
