import CoreLocation
import KakaoSDKCommon
import NMapsMap
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Secrets.kakaoAuthAppKey)
        NMFAuthManager.shared().clientId = Secrets.naverMapClientID

        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        self.registerDependencies()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// MARK: - Dependency
extension AppDelegate {
    /// 의존성 등록을 위한 메서드
    private func registerDependencies() {
        // MARK: Register Service
        DIContainer.register(KeyChainService.self) { return KeyChainService() }
    }
}
