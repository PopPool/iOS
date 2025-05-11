import UIKit

import Domain
import DomainInterface
import Infrastructure
import SearchFeatureInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController()
        @Dependency var popupSearchFactory: PopupSearchFactory

        navigationController.pushViewController(
            popupSearchFactory.make(),
            animated: false
        )

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
