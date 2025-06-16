import UIKit

import DesignSystem

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class CommentSelectedController: BaseViewController, View {

    typealias Reactor = CommentSelectedReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = CommentSelectedView()
}

// MARK: - Life Cycle
extension CommentSelectedController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension CommentSelectedController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension CommentSelectedController {
    func bind(reactor: Reactor) {
        mainView.cancelButton.rx.tap
            .map { _ in
                Reactor.Action.cancelButtonTapped
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.normalCommentButton.rx.tap
            .map { _ in
                Reactor.Action.normalButtonTapped
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.instaCommentButton.rx.tap
            .map { _ in
                Reactor.Action.instaButtonTapped
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension CommentSelectedController: PanModalPresentable {
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
