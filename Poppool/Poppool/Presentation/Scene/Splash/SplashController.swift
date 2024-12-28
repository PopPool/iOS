//
//  SplashController.swift
//  Poppool
//
//  Created by Porori on 11/26/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class SplashController: BaseViewController, View {
    
    typealias Reactor = ReactorConvention
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = SplashView()
}

// MARK: - Life Cycle
extension SplashController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension SplashController {
    func setUp() {
        view.backgroundColor = .blu500
        
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension SplashController {
    func bind(reactor: Reactor) {
    }
}
