//
//  MyCommentController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/8/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class MyCommentController: BaseViewController, View {
    
    typealias Reactor = MyCommentReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = MyCommentView()
}

// MARK: - Life Cycle
extension MyCommentController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - SetUp
private extension MyCommentController {
    func setUp() {
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension MyCommentController {
    func bind(reactor: Reactor) {
    }
}
