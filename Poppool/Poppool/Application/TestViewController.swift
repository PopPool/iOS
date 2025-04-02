//
//  ViewController.swift
//  Poppool
//
//  Created by Porori on 11/24/24.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift
import SnapKit

class TestViewController: UIViewController {

    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .w100
        view.alpha = 0
        return view
    }()

    private let topViewLabel: UILabel = {
        let label = UILabel()
        label.text = "Top View Label"
        return label
    }()

    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .w100
        return view
    }()

    private let gestureBar: UIView = {
        let view = UIView()
        view.backgroundColor = .g200
        return view
    }()

    private let listButton: PPButton = {
        return PPButton(style: .secondary, text: "리스트 버튼")
    }()

    private let disposeBag = DisposeBag()

    private var bottomViewTopConstraints: Constraint?

    enum ModalState {
        case top
        case middle
        case bottom
    }

    var modalState: ModalState = .bottom

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        setUpConstratins()
        bind()
    }

    func setUpConstratins() {
        view.addSubview(listButton)
        listButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(104)
        }

        topView.addSubview(topViewLabel)
        topViewLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            bottomViewTopConstraints = make.top.equalTo(topView.snp.bottom).offset(700).constraint
            make.height.equalTo(700)
        }

        bottomView.addSubview(gestureBar)
        gestureBar.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(20)
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
    }

    func bind() {
        listButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                print("listButtonTapped")
                UIView.animate(withDuration: 0.3) {
                    owner.bottomViewTopConstraints?.update(offset: 124)
                    owner.topView.alpha = 0
                    owner.view.layoutIfNeeded()
                    owner.modalState = .middle
                }
            }
            .disposed(by: disposeBag)

        gestureBar.rx.swipeGesture(.up)
            .skip(1)
            .withUnretained(self)
            .subscribe { (owner, _) in
                print("swipe up")
                UIView.animate(withDuration: 0.3) {
                    owner.bottomViewTopConstraints?.update(offset: 0)
                    owner.topView.alpha = 1
                    owner.view.layoutIfNeeded()
                    owner.modalState = .top
                }
            }
            .disposed(by: disposeBag)

        gestureBar.rx.swipeGesture(.down)
            .skip(1)
            .withUnretained(self)
            .subscribe { (owner, _) in
                print("swipe down")
                switch owner.modalState {
                case .top:
                    UIView.animate(withDuration: 0.3) {
                        owner.bottomViewTopConstraints?.update(offset: 124)
                        owner.topView.alpha = 0
                        owner.view.layoutIfNeeded()
                        owner.modalState = .middle
                    }
                case .middle:
                    UIView.animate(withDuration: 0.3) {
                        owner.bottomViewTopConstraints?.update(offset: 700)
                        owner.topView.alpha = 0
                        owner.view.layoutIfNeeded()
                        owner.modalState = .bottom
                    }
                case .bottom:
                    break
                }

            }
            .disposed(by: disposeBag)
    }
}
