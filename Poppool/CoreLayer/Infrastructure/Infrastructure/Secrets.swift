import Foundation

public enum Secrets {
    public static var kakaoAuthAppKey: String {
        return getValue(forKey: "KAKAO_AUTH_APP_KEY")
    }

    public static var popPoolBaseURL: String {
        return getValue(forKey: "POPPOOL_BASE_URL")
    }

    public static var popPoolS3BaseURL: String {
        return getValue(forKey: "POPPOOL_S3_BASE_URL")
    }

    public static var popPoolAPIKey: String {
        return getValue(forKey: "POPPOOL_API_KEY")
    }

    public static var naverMapClientID: String {
        return getValue(forKey: "NAVER_MAP_CLIENT_ID")
    }

    private static func getValue(forKey key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("Missing key: \(key) in Info.plist")
        }
        return value
    }
}
