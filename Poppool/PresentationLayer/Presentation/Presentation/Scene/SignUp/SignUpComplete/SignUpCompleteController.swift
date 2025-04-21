//
//  SignUpCompleteController.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/27/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class SignUpCompleteController: BaseViewController, View {

    typealias Reactor = SignUpCompleteReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = SignUpCompleteView()
}

// MARK: - Life Cycle
extension SignUpCompleteController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension SignUpCompleteController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SignUpCompleteController {
    func bind(reactor: Reactor) {

        mainView.bottomButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.completeButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.3
                paragraphStyle.alignment = .center
                owner.mainView.nickNameLabel.attributedText = NSMutableAttributedString(
                    string: state.nickName,
                    attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
                )
                let categoryString = state.categoryTitles.enumerated()
                    .map { "#\($0.element)" }
                    .joined(separator: ", ")

                let attributedText = NSMutableAttributedString(
                    string: categoryString,
                    attributes: [
                        .font: UIFont.korFont(style: .bold, size: 15)!,
                        .foregroundColor: UIColor.g600,
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ]
                )
                attributedText.append(NSAttributedString(string: "와 연관된 팝업스토어 정보를 안내해드릴게요.", attributes: [
                    .font: UIFont.korFont(style: .regular, size: 15)!,
                    .foregroundColor: UIColor.g600,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                ]))
                owner.mainView.descriptionLabel.attributedText = attributedText
            }
            .disposed(by: disposeBag)
    }
}
