//
//  AppDelegate.swift
//  Poppoolasdasdasdasda
//
//  Created by Porori on 11/24/24.
//
import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import RxKakaoSDKCommon
import NMapsMap
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        RxKakaoSDK.initSDK(appKey: Secrets.kakaoAuthAppkey.rawValue, loggingEnable: false)


        NMFAuthManager.shared().clientId = Secrets.naverMapClientId.rawValue

        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization() 

        return true
    }


}
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }


}