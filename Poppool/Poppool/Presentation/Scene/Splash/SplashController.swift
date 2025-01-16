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

final class SplashController: BaseViewController {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = SplashView()
    private let authAPIUseCase = AuthAPIUseCaseImpl(repository: AuthAPIRepositoryImpl(provider: ProviderImpl()))
    private let keyChainService = KeyChainService()
    
    private var rootViewController: UIViewController?
}

// MARK: - Life Cycle
extension SplashController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setRootview()
        playAnimation()
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
    
    func playAnimation() {
        mainView.animationView.play { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.changeRootView()
            }
        }
    }
    
    func setRootview() {
        authAPIUseCase.postTokenReissue()
            .withUnretained(self)
            .subscribe(onNext: { (owner, response) in
                let newAccessToken = response.accessToken ?? ""
                let newRefreshToken = response.refreshToken ?? ""
                let _ = owner.keyChainService.saveToken(type: .accessToken, value: newAccessToken)
                let _ = owner.keyChainService.saveToken(type: .refreshToken, value: newRefreshToken)
                let navigationController = WaveTabBarController()
                owner.rootViewController = navigationController
            }, onError: { [weak self] _ in
                guard let self = self else { return }
                let loginViewController = LoginController()
                loginViewController.reactor = LoginReactor()
                let loginNavigationController = UINavigationController(rootViewController: loginViewController)
                rootViewController = loginNavigationController
            })
            .disposed(by: disposeBag)
    }
    
    func changeRootView() {
        view.window?.rootViewController = rootViewController
        view.window?.makeKeyAndVisible()
    }
}
