//
//  CommentCheckController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class CommentCheckController: BaseViewController, View {

    typealias Reactor = CommentCheckReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = CommentCheckView()
}

// MARK: - Life Cycle
extension CommentCheckController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension CommentCheckController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension CommentCheckController {
    func bind(reactor: Reactor) {
        mainView.continueButton.rx.tap
            .map { Reactor.Action.continueButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.stopButton.rx.tap
            .map { Reactor.Action.stopButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension CommentCheckController: PanModalPresentable {
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
