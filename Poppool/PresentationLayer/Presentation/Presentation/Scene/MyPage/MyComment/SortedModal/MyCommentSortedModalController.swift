import UIKit

import DesignSystem

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class MyCommentSortedModalController: BaseViewController, View {

    typealias Reactor = MyCommentSortedModalReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = MyCommentSortedModalView()
}

// MARK: - Life Cycle
extension MyCommentSortedModalController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension MyCommentSortedModalController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension MyCommentSortedModalController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.sortedSegmentControl.rx.selectedSegmentIndex
            .skip(1)
            .map { Reactor.Action.selectedSegmentControl(row: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.saveButton.rx.tap
            .withUnretained(self)
            .compactMap { (owner, _) in
                Reactor.Action.saveButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.xmarkButton.rx.tap
            .withUnretained(self)
            .compactMap { (owner, _) in
                Reactor.Action.xmarkButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                if state.isSetView {
                    if state.originSortedCode == "NEWEST" {
                        owner.mainView.sortedSegmentControl.selectedSegmentIndex = 0
                    } else {
                        owner.mainView.sortedSegmentControl.selectedSegmentIndex = 1
                    }
                }
                owner.mainView.saveButton.isEnabled = state.saveButtonIsEnabled
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension MyCommentSortedModalController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(250)
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(250)
    }
    var showDragIndicator: Bool {
        return false
    }
    var cornerRadius: CGFloat {
        return 20
    }
}
