import UIKit

import Domain
import DomainInterface
import Infrastructure
import SearchFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var coordinator: SearchFeatureCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController()

        coordinator = SearchFeatureCoordinator(navigationController: navigationController)
        coordinator?.start()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

