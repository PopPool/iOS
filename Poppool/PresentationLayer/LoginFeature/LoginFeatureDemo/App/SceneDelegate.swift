import UIKit

import LoginFeatureInterface
import Infrastructure

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController()
        @Dependency var factory: LoginFactory

        navigationController.pushViewController(
            factory.make(),
            animated: false
        )

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

