import UIKit
import CryptoKit

/// 디스크에 이미지를 캐싱하는 클래스
final class DiskStorage {
    
    /// 싱글톤 인스턴스
    static let shared = DiskStorage()
    
    /// 파일 관리 객체
    private let fileManager = FileManager.default
    
    /// 이미지 캐시 디렉터리 경로
    private let cacheDirectory: URL
    
    /// 초기화 메서드 (캐시 디렉터리 생성 및 자동 삭제 스케줄 시작)
    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("ImageCache")
        
        // 디렉터리가 존재하지 않으면 생성
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        startCacheCleanup()
    }
    
    /// URL을 안전한 파일명으로 변환하는 메서드
    /// - Parameter url: 원본 URL 문자열
    /// - Returns: 파일명으로 변환된 문자열
    private func cacheFileName(for url: String) -> String {
        let data = Data(url.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// 이미지를 디스크에 저장하는 메서드
    /// - Parameters:
    ///   - image: 저장할 UIImage 객체
    ///   - url: 해당 이미지의 원본 URL 문자열
    func store(image: UIImage, url: String) {
        let fileName = cacheFileName(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        let metadataURL = cacheDirectory.appendingPathComponent("\(fileName).metadata")
        
        // 이미지 데이터를 JPEG 형식으로 변환하여 저장
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: fileURL)
            } catch {
                print("Error writing image data to disk: \(error)")
            }
        }
        
        // 만료 시간 기록
        let expirationDate = Date().addingTimeInterval(ImageLoader.shared.configure.diskCacheExpiration)
        let metadata = ["expiration": expirationDate.timeIntervalSince1970]
        
        // 만료 정보를 JSON 형태로 저장
        if let metadataData = try? JSONSerialization.data(withJSONObject: metadata) {
            do {
                try metadataData.write(to: metadataURL)
            } catch {
                print("Error writing metadata: \(error)")
            }
        }
    }
    
    /// 디스크에서 이미지를 불러오는 메서드 (만료된 경우 자동 삭제)
    /// - Parameter url: 이미지의 원본 URL 문자열
    /// - Returns: UIImage 객체 (없거나 만료된 경우 nil)
    func fetchImage(url: String) -> UIImage? {
        let fileName = cacheFileName(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        let metadataURL = cacheDirectory.appendingPathComponent("\(fileName).metadata")
        
        // 만료 시간 확인
        if let metadataData = try? Data(contentsOf: metadataURL),
           let metadata = try? JSONSerialization.jsonObject(with: metadataData) as? [String: TimeInterval],
           let expirationTime = metadata["expiration"] {
            
            // 만료 시간이 현재 시각을 초과하면 삭제 후 nil 반환
            if Date().timeIntervalSince1970 > expirationTime {
                removeImage(url: url)
                return nil
            }
        }
        
        // 이미지 파일이 존재하면 로드하여 반환
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    /// 특정 URL에 해당하는 이미지를 디스크에서 삭제하는 메서드
    /// - Parameter url: 삭제할 이미지의 원본 URL 문자열
    func removeImage(url: String) {
        let fileName = cacheFileName(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        let metadataURL = cacheDirectory.appendingPathComponent("\(fileName).metadata")
        
        do {
            try fileManager.removeItem(at: fileURL)     // 이미지 파일 삭제
            try fileManager.removeItem(at: metadataURL) // 메타데이터 파일 삭제
        } catch {
            print("Failed to remove image: \(error)")
        }
    }
    
    /// 모든 캐시 데이터를 삭제하는 메서드
    func clearCache() {
        do {
            try fileManager.removeItem(at: cacheDirectory)
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
    
    /// 주기적으로 만료된 캐시를 삭제하는 메서드
    /// - 5분(300초)마다 실행되며, 만료된 이미지와 메타데이터를 정리함.
    private func startCacheCleanup() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let cleanTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                let files = (try? self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: nil)) ?? []

                for file in files {
                    if file.pathExtension == "metadata",
                       let metadataData = try? Data(contentsOf: file),
                       let metadata = try? JSONSerialization.jsonObject(with: metadataData) as? [String: TimeInterval],
                       let expirationTime = metadata["expiration"] {

                        // 만료 시간이 지나면 이미지와 메타데이터 삭제
                        if Date().timeIntervalSince1970 > expirationTime {
                            let imageFileURL = file.deletingPathExtension() // 메타데이터와 동일한 이름의 이미지 파일
                            do {
                                try self.fileManager.removeItem(at: imageFileURL)
                                try self.fileManager.removeItem(at: file) // 메타데이터 삭제
                            } catch {
                                print("Failed to delete expired cache: \(error)")
                            }
                        }
                    }
                }
            }
            // 백그라운드에서 실행되는 타이머를 메인 루프에 추가
            RunLoop.current.add(cleanTimer, forMode: .common)
            RunLoop.current.run() // 백그라운드 스레드에서 타이머를 계속 실행하기 위해 RunLoop를 유지
        }
    }
}
