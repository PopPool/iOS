import CoreLocation
import KakaoSDKCommon
import NMapsMap
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: KeyPath.kakaoAuthAppKey)
        NMFAuthManager.shared().clientId = KeyPath.naverMapClientID

        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
