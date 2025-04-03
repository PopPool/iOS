import UIKit
import KakaoSDKCommon
import CoreLocation
import NMapsMap

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Secrets.kakaoAuthAppkey.rawValue)
        NMFAuthManager.shared().clientId = Secrets.naverMapClientId.rawValue

        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
