import UIKit

import DesignSystem
import Infrastructure

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class FilterSelectViewController: BaseViewController, View {

    typealias Reactor = FilterSelectReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = FilterSelectView()
}

// MARK: - Life Cycle
extension FilterSelectViewController {
    override func loadView() {
        self.view = mainView
    }
}

// MARK: - Methods
extension FilterSelectViewController {
    func bind(reactor: Reactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }

    private func bindAction(reactor: Reactor) {
        mainView.closeButton.rx.tap
            .map { _ in Reactor.Action.closeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.statusSegmentControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .map { (owner, _) in Reactor.Action.statusSegmentChanged(index: owner.mainView.statusSegmentControl.selectedSegmentIndex) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.sortSegmentControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .map { (owner, _) in Reactor.Action.sortSegmentChanged(index: owner.mainView.sortSegmentControl.selectedSegmentIndex) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.saveButton.rx.tap
            .withUnretained(self)
            .map { (_, _) in Reactor.Action.saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindState(reactor: Reactor) {
        reactor.state.distinctUntilChanged(\.selectedFilter)
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.statusSegmentControl.selectedSegmentIndex = state.selectedFilter.status.index
                owner.mainView.sortSegmentControl.selectedSegmentIndex = state.selectedFilter.sort.index
            }
            .disposed(by: disposeBag)

        reactor.state.distinctUntilChanged(\.saveButtonIsEnable)
            .withUnretained(self)
            .subscribe { (owner, state) in owner.mainView.saveButton.isEnabled = state.saveButtonIsEnable }
            .disposed(by: disposeBag)

        reactor.pulse(\.$dismiss)
            .withUnretained(self)
            .subscribe { (owner, _) in owner.dismissModal() }
            .disposed(by: disposeBag)

        reactor.pulse(\.$filterChanged)
            .skip(1)
            .subscribe { _ in Filter.valueChanged.onNext(()) }
            .disposed(by: disposeBag)
    }
}

extension FilterSelectViewController: PPModalPresentable {
    var modalHeight: CGFloat? { return 379 }

    var backgroundColor: UIColor { return .pb60 }

    var cornerRadius: CGFloat { return 20 }
}
