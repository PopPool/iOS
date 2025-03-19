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
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }



