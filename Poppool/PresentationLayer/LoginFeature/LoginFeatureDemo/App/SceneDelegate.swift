import UIKit

import Infrastructure
import LoginFeatureInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController()
        @Dependency var factory: LoginFactory

        navigationController.pushViewController(
            factory.make(.main, text: "간편하게 SNS 로그인하고\n팝풀 서비스를 이용해보세요"),
            animated: false
        )

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
