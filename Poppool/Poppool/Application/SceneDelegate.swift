////
////  SceneDelegate.swift
////  Poppool
////
////  Created by Porori on 11/24/24.
////
//
//import UIKit
//import RxKakaoSDKAuth
//import KakaoSDKAuth
//import RxSwift
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//   var window: UIWindow?
//   static let appDidBecomeActive = PublishSubject<Void>()
//
//   func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//       guard let windowScene = (scene as? UIWindowScene) else { return }
//       window = UIWindow(windowScene: windowScene)
//
//       // Debug: Admin Page Test
//       let provider = ProviderImpl()
//       let repository = DefaultAdminRepository(provider: provider)
//       let useCase = DefaultAdminUseCase(repository: repository)
//       let reactor = AdminReactor(useCase: useCase)
//       let adminVC = AdminViewController()
//       adminVC.reactor = reactor
//
//       let navigationController = UINavigationController(rootViewController: adminVC)
//
//        let rootViewController = LoginController()
//        rootViewController.reactor = LoginReactor()
//
//        let rootVC = WaveTabBarController()
//
//        let rootViewController = DetailController()
//        rootViewController.reactor = DetailReactor(popUpID: 8)
//
//        let rootViewController = SearchMainController()
//        rootViewController.reactor = SearchMainReactor()
//
//        let navigationController = UINavigationController(rootViewController: rootVC)
//        let navigationController = WaveTabBarController()
//
//       window?.rootViewController = navigationController
//       window?.makeKeyAndVisible()
//   }
//
//   func sceneDidDisconnect(_ scene: UIScene) {
//   }
//
//   func sceneDidBecomeActive(_ scene: UIScene) {
//       SceneDelegate.appDidBecomeActive.onNext(())
//   }
//
//   func sceneWillResignActive(_ scene: UIScene) {
//   }
//
//   func sceneWillEnterForeground(_ scene: UIScene) {
//   }
//
//   func sceneDidEnterBackground(_ scene: UIScene) {
//   }
//
//   func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//       if let url = URLContexts.first?.url {
//           if AuthApi.isKakaoTalkLoginUrl(url) {
//               _ = AuthController.rx.handleOpenUrl(url: url)
//           }
//       }
//   }
//}
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
    private let disposeBag = DisposeBag()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplashController()
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

