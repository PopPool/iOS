//
//  ImageDetailController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class ImageDetailController: BaseViewController, View {

    typealias Reactor = ImageDetailReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = ImageDetailView()

    private let cancelButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "icon_xmark_white"), for: .normal)
        return view
    }()
}

// MARK: - Life Cycle
extension ImageDetailController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension ImageDetailController {
    func setUp() {
        view.backgroundColor = .clear
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}

// MARK: - Methods
extension ImageDetailController {
    func bind(reactor: Reactor) {

        cancelButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.backButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                owner.mainView.imageView.setPPImage(path: state.imagePath)
            }
            .disposed(by: disposeBag)
    }
}
