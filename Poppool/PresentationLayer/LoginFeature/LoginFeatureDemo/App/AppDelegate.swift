import UIKit

import Infrastructure
import LoginFeature
import LoginFeatureInterface

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.registerDependencies()
        self.registerFactory()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate {
    private func registerDependencies() {
        // MARK: Register Service

        // MARK: Resolve service

        // MARK: Register repository

        // MARK: Resolve repository

        // MARK: Register UseCase
        
    }

    private func registerFactory() {
        DIContainer.register(LoginFactory.self) { return LoginFactoryImpl() }
    }
}
