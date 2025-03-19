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
import UIKit

import KakaoSDKCommon
import GoogleMaps
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Secrets.kakaoAuthAppkey.rawValue)
        GMSServices.provideAPIKey(Secrets.popPoolApiKey.rawValue)
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization() // 권한 요청 초기화
        
        return true
        }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

