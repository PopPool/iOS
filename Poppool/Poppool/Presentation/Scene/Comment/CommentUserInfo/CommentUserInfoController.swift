//
//  CommentUserInfoController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import PanModal

final class CommentUserInfoController: BaseViewController, View {
    
    typealias Reactor = CommentUserInfoReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = CommentUserInfoView()
}

// MARK: - Life Cycle
extension CommentUserInfoController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension CommentUserInfoController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension CommentUserInfoController {
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
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.titleLabel.setLineHeightText(
                    text: "\(state.nickName ?? "")님에 대해 더 알아보기",
                    font: .KorFont(style: .bold, size: 18)
                )
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension CommentUserInfoController: PanModalPresentable {
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
