//
//  SceneDelegate.swift
//  Poppool
//
//  Created by Porori on 11/24/24.
//

import UIKit

import RxKakaoSDKAuth
import KakaoSDKAuth
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    static let appDidBecomeActive = PublishSubject<Void>()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        
        let rootViewController = LoginController()
        rootViewController.reactor = LoginReactor()
        
        
//        let rootViewController = DetailController()
//        rootViewController.reactor = DetailReactor(popUpID: 8)
        
//        let rootViewController = SearchMainController()
//        rootViewController.reactor = SearchMainReactor()
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
//        let navigationController = WaveTabBarController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        SceneDelegate.appDidBecomeActive.onNext(())
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
}

