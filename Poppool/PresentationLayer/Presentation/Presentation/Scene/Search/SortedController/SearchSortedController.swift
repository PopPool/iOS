import UIKit

import DesignSystem

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class SearchSortedController: BaseViewController, View {

    typealias Reactor = SearchSortedReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = SearchSortedView()
}

// MARK: - Life Cycle
extension SearchSortedController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension SearchSortedController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SearchSortedController {
    func bind(reactor: Reactor) {
        mainView.closeButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.closeButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.filterSegmentControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .map({ (owner, _) in
                Reactor.Action.changeFilterIndex(index: owner.mainView.filterSegmentControl.selectedSegmentIndex)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.sortedSegmentControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .map({ (owner, _) in
                Reactor.Action.changeSortedIndex(index: owner.mainView.sortedSegmentControl.selectedSegmentIndex)
            })
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
                owner.mainView.filterSegmentControl.selectedSegmentIndex = state.filterIndex
                owner.mainView.sortedSegmentControl.selectedSegmentIndex = state.sortedIndex
                owner.mainView.saveButton.isEnabled = state.saveButtonIsEnable
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension SearchSortedController: PanModalPresentable {
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
