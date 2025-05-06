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
        mainView.closeButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in owner.dismiss(animated: true) })
            .disposed(by: disposeBag)

        mainView.statusSegmentControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .map { (owner, _) in
                if owner.mainView.statusSegmentControl.selectedSegmentIndex == 0 {
                    Reactor.Action.changeStatus(status: .open)
                } else { Reactor.Action.changeStatus(status: .closed) }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.sortSegmentControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .map { (owner, _) in
                if owner.mainView.sortSegmentControl.selectedSegmentIndex == 0 {
                    Reactor.Action.changeSort(sort: .newest)
                } else { Reactor.Action.changeSort(sort: .popularity) }
            }
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
                owner.mainView.statusSegmentControl.selectedSegmentIndex = state.selectedFilter.status.index
                owner.mainView.sortSegmentControl.selectedSegmentIndex = state.selectedFilter.sort.index
                owner.mainView.saveButton.isEnabled = state.saveButtonIsEnable
            }
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
