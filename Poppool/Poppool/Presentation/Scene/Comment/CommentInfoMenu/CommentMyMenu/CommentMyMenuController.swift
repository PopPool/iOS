//
//  CommentMyMenuController.swift
//  Poppool
//
//  Created by SeoJunYoung on 2/1/25.
//

import UIKit

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class CommentMyMenuController: BaseViewController, View {

    typealias Reactor = CommentMyMenuReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = CommentMyMenuView()
}

// MARK: - Life Cycle
extension CommentMyMenuController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension CommentMyMenuController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension CommentMyMenuController {
    func bind(reactor: Reactor) {
        mainView.cancelButton.rx.tap
            .map { _ in
                Reactor.Action.cancelButtonTapped
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.commentRemoveButton.rx.tap
            .map { _ in
                Reactor.Action.removeButtonTapped
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.commentEditButton.rx.tap
            .map { _ in
                Reactor.Action.editButtonTapped
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension CommentMyMenuController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    var longFormHeight: PanModalHeight {
        return .contentHeightIgnoringSafeArea(226)
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeightIgnoringSafeArea(226)
    }
    var showDragIndicator: Bool {
        return false
    }
    var cornerRadius: CGFloat {
        return 20
    }
}
