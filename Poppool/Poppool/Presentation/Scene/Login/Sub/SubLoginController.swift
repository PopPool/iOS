//
//  SubLoginController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/28/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class SubLoginController: BaseViewController, View {
    
    typealias Reactor = SubLoginReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = SubLoginView()
}

// MARK: - Life Cycle
extension SubLoginController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension SubLoginController {
    func setUp() {
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SubLoginController {
    func bind(reactor: Reactor) {
        mainView.xmarkButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.xmarkButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.kakaoButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.kakaoButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.appleButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.appleButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
