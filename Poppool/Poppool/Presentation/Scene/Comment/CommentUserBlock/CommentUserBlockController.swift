//
//  CommentUserBlockController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import UIKit

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class CommentUserBlockController: BaseViewController, View {

    typealias Reactor = CommentUserBlockReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = CommentUserBlockView()
}

// MARK: - Life Cycle
extension CommentUserBlockController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension CommentUserBlockController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension CommentUserBlockController {
    func bind(reactor: Reactor) {
        mainView.cancelButton.rx.tap
            .map { Reactor.Action.stopButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.blockButton.rx.tap
            .map { Reactor.Action.continueButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.titleLabel.setLineHeightText(
                    text: "\(state.nickName ?? "")님을 차단할까요?",
                    font: .KorFont(style: .bold, size: 18)
                )
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension CommentUserBlockController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(170)
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(170)
    }
    var showDragIndicator: Bool {
        return false
    }
    var cornerRadius: CGFloat {
        return 20
    }
}
