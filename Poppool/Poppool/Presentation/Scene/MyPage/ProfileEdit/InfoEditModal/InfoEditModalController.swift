//
//  InfoEditModalController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/10/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import PanModal

final class InfoEditModalController: BaseViewController, View {
    
    typealias Reactor = InfoEditModalReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = InfoEditModalView()
}

// MARK: - Life Cycle
extension InfoEditModalController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension InfoEditModalController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension InfoEditModalController {
    func bind(reactor: Reactor) {
        mainView.xmarkButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.xmarkButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.genderSegmentControl.rx.selectedSegmentIndex
            .map { Reactor.Action.changeGender(index: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.ageButton.button.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.ageButtonTapped(controller: owner)
            }
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
                if state.isLoadView {
                    guard let gender = state.gender else { return }
                    owner.mainView.genderSegmentControl.selectedSegmentIndex = gender == "선택안함" ? 2 : gender == "남성" ? 0 : 1
                }
                owner.mainView.ageButton.injection(with: .init(age: Int(state.age)))
                owner.mainView.saveButton.isEnabled = state.saveButtonEnable
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension InfoEditModalController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(390)
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(390)
    }
    var showDragIndicator: Bool {
        return false
    }
    var cornerRadius: CGFloat {
        return 20
    }
}
