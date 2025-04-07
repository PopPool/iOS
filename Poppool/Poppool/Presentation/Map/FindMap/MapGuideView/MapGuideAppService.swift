import CoreLocation
import UIKit

enum MapAppType {
    case naver
    case kakao
    case apple

    static func from(string: String) -> MapAppType? {
        switch string.lowercased() {
        case "naver":
            return .naver
        case "kakao":
            return .kakao
        case "apple", "applemap":
            return .apple
        default:
            return nil
        }
    }

    func urlScheme(coordinate: CLLocationCoordinate2D, name: String, address: String) -> String {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        switch self {
        case .naver:
            return "nmap://place?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&name=\(encodedName)&addr=\(encodedAddress)&appname=com.poppool.app"
        case .kakao:
            return "kakaomap://look?p=\(coordinate.latitude),\(coordinate.longitude)"
        case .apple:
            return "maps://?q=\(encodedName)&ll=\(coordinate.latitude),\(coordinate.longitude)&z=16"
        }
    }

    var appStoreURL: String {
        switch self {
        case .naver:
            return "https://apps.apple.com/kr/app/id311867728"
        case .kakao:
            return "https://apps.apple.com/kr/app/id304608425"
        case .apple:
            return "https://apps.apple.com/kr/app/id1108185179"
        }
    }
}

class MapAppService {
    static func openMapApp(_ appTypeString: String, coordinate: CLLocationCoordinate2D, name: String, address: String) -> Observable<String?> {
        guard let appType = MapAppType.from(string: appTypeString) else {
            return Observable.just("지원하지 않는 맵 앱입니다.")
        }

        let urlScheme = appType.urlScheme(coordinate: coordinate, name: name, address: address)

        Logger.log(message: "🗺 맵 앱 열기 시도: \(urlScheme)", category: .debug)

        if let url = URL(string: urlScheme), UIApplication.shared.canOpenURL(url) {
            Logger.log(message: "✅ \(appType) 앱 실행", category: .debug)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return Observable.empty()
        } else {
            Logger.log(message: "❌ \(appType) 앱 미설치 - 앱스토어로 이동", category: .debug)
            if let appStoreURL = URL(string: appType.appStoreURL) {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                return Observable.just("\(appTypeString) 앱이 설치되어 있지 않아 앱스토어로 이동합니다.")
            }
            return Observable.just("앱을 열 수 없습니다.")
        }
    }
}
