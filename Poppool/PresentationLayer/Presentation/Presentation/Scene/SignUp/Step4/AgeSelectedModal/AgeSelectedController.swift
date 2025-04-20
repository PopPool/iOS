//
//  AgeSelectedController.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/26/24.
//

import UIKit

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class AgeSelectedController: BaseViewController, View {

    typealias Reactor = AgeSelectedReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = AgeSelectedView()
}

// MARK: - Life Cycle
extension AgeSelectedController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension AgeSelectedController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension AgeSelectedController {
    func bind(reactor: Reactor) {
        mainView.cancelButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.cancelButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.completeButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                let selectedAge = owner.mainView.picker.pickerView.selectedRow(inComponent: 0)
                return Reactor.Action.completeButtonTapped(selectedAge: selectedAge, controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                if let selectedAge = state.selectedAge {
                    owner.mainView.picker.setIndex(index: selectedAge)
                } else {
                    owner.mainView.picker.setIndex(index: 30)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension AgeSelectedController: PanModalPresentable {
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
