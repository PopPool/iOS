import UIKit

import DesignSystem

import PanModal
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            .map { (owner, _) in Reactor.Action.saveButtonTapped }
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
            .subscribe { (owner, _) in owner.dismiss(animated: true) }
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension FilterSelectViewController: PanModalPresentable {
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
