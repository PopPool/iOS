import UIKit

import Domain
import DomainInterface
import Infrastructure

import SearchFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let vc = PopupSearchViewController()
        vc.reactor = PopupSearchReactor(
            popupAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
            fetchKeywordBasePopupListUseCase: DIContainer.resolve(FetchKeywordBasePopupListUseCase.self)
        )
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

