import UIKit

/// 캐시할 이미지와 만료 시간을 저장하는 클래스
class StorageData: NSObject {
    let image: UIImage? /// 캐시된 이미지
    let expirationDate: Date /// 캐시 만료 시간

    /// 초기화 메서드
    /// - Parameters:
    ///   - image: 저장할 이미지
    ///   - expiration: 만료 시간 (초 단위)
    init(image: UIImage?, expiration: TimeInterval) {
        self.image = image
        self.expirationDate = Date().addingTimeInterval(expiration)
    }

    /// 캐시가 만료되었는지 확인하는 메서드
    /// - Returns: 만료 여부 (true: 만료됨, false: 유효함)
    func isExpired() -> Bool {
        return Date() > expirationDate
    }
}

/// 메모리 캐시를 관리하는 클래스
final class MemoryStorage {

    /// 싱글톤 인스턴스
    static let shared = MemoryStorage()

    /// 이미지 캐시 저장소
    private let cache = NSCache<NSString, StorageData>()

    /// 현재 캐시에 저장된 키 목록
    private var cachedKeys: Set<String> = []

    /// 초기화 (자동 캐시 정리 시작)
    private init() {
        startCacheCleanup()
    }

    /// 이미지를 캐시에 저장하는 메서드
    /// - Parameters:
    ///   - image: 저장할 이미지
    ///   - url: 이미지 URL 문자열
    func store(image: UIImage?, url: String) {
        let cachedData = StorageData(image: image, expiration: ImageLoader.shared.configure.memoryCacheExpiration)
        cache.setObject(cachedData, forKey: url as NSString)
        cachedKeys.insert(url)
    }

    /// 캐시에서 이미지를 가져오는 메서드
    /// - Parameter url: 이미지 URL 문자열
    /// - Returns: 캐시된 UIImage (없으면 nil)
    func fetchImage(url: String) -> UIImage? {
        if let cachedData = cache.object(forKey: url as NSString), !cachedData.isExpired() {
            return cachedData.image
        } else {
            removeData(url: url)
            return nil
        }
    }

    /// 특정 URL의 캐시 데이터를 제거하는 메서드
    /// - Parameter url: 제거할 이미지의 URL 문자열
    func removeData(url: String) {
        cache.removeObject(forKey: url as NSString)
        cachedKeys.remove(url)
    }

    /// 모든 캐시 데이터를 삭제하는 메서드
    func clearCache() {
        cache.removeAllObjects()
        cachedKeys.removeAll()
    }

    /// 주기적으로 만료된 캐시를 정리하는 메서드
    private func startCacheCleanup() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let cleanTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                for key in self.cachedKeys {
                    let nsKey = key as NSString
                    if let cachedData = self.cache.object(forKey: nsKey), cachedData.isExpired() {
                        self.cache.removeObject(forKey: nsKey)
                        self.cachedKeys.remove(key)
                    }
                }
            }
            // 백그라운드에서 실행되는 타이머를 메인 루프에 추가
            RunLoop.current.add(cleanTimer, forMode: .common)
            RunLoop.current.run() // 백그라운드 스레드에서 타이머를 계속 실행하기 위해 RunLoop를 유지
        }
    }
}
