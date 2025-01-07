//
//  ProfileEditController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/4/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class ProfileEditController: BaseViewController, View {
    
    typealias Reactor = ProfileEditReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = ProfileEditView()
}

// MARK: - Life Cycle
extension ProfileEditController {
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
private extension ProfileEditController {
    func setUp() {
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension ProfileEditController {
    func bind(reactor: Reactor) {
    }
}
