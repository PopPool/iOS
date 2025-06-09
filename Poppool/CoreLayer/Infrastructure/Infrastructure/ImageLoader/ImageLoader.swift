import UIKit

enum ImageLoaderError: Error {
    case invalidURL
    case networkError(description: String?)
    case convertError(description: String?)
}

enum ImageSizeOption {
    case low
    case middle
    case high
    case origin

    var size: CGSize {
        switch self {
        case .low:
            return CGSize(width: 100, height: 100)
        case .middle:
            return CGSize(width: 200, height: 200)
        case .high:
            return CGSize(width: 400, height: 400)
        case .origin:
            return CGSize(width: 1000, height: 1000)
        }
    }
}

/// 이미지 로더 설정 클래스
/// - `memoryCacheExpiration`: 메모리 캐시 만료 시간 (기본값 300초)
class ImageLoaderConfigure {
    var memoryCacheExpiration: TimeInterval = 300
    var diskCacheExpiration: TimeInterval = 86_400
}

/// URL을 통해 이미지를 비동기적으로 로드하는 클래스
final class ImageLoader {

    static let shared = ImageLoader()

    /// 이미지 로더 설정 객체
    let configure = ImageLoaderConfigure()

    private init() {}

    /// URL을 통해 이미지를 로드하고, 실패 시 기본 이미지를 반환하는 메서드
    /// - Parameters:
    ///   - stringURL: 이미지 URL 문자열
    ///   - defaultImage: 로드 실패 시 반환할 기본 이미지
    ///   - completion: 로드 완료 후 호출되는 클로저
    func loadImage(
        with stringURL: String?,
        defaultImage: UIImage?,
        imageQuality: ImageSizeOption = .origin,
        completion: @escaping (UIImage?) -> Void
    ) {
        loadImage(with: stringURL) { [weak self] result in
            switch result {
            case .success(let image):
                completion(self?.resizeImage(image, defaultImage: defaultImage, with: imageQuality))
            case .failure:
                completion(defaultImage)
            }
        }
    }
}

private extension ImageLoader {

    /// URL을 통해 이미지를 로드하는 내부 메서드
    /// - Parameters:
    ///   - stringURL: 이미지 URL 문자열
    ///   - completion: 로드 완료 후 호출되는 클로저
    func loadImage(with stringURL: String?, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let stringURL = stringURL, let url = URL(string: stringURL) else {
            completion(.failure(ImageLoaderError.invalidURL))
            return
        }

        // 메모리 캐시에서 이미지 조회
        if let cachedImage = MemoryStorage.shared.fetchImage(url: stringURL) {
            completion(.success(cachedImage))
            return
        }

        // 디스크 캐시 확인
        if let diskImage = DiskStorage.shared.fetchImage(url: stringURL) {
            // 메모리 캐시에 저장 후 반환
            MemoryStorage.shared.store(image: diskImage, url: stringURL)
            completion(.success(diskImage))
            return
        }

        // 네트워크에서 데이터 요청
        fetchDataFrom(url: url) { result in
            switch result {
            case .success(let data):
                if let data = data, let image = UIImage(data: data) {
                    MemoryStorage.shared.store(image: image, url: stringURL)
                    DiskStorage.shared.store(image: image, url: stringURL)
                    DispatchQueue.main.async { completion(.success(image)) }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(ImageLoaderError.convertError(description: "Failed to convert data to UIImage")))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    /// URL을 통해 데이터를 요청하는 메서드
    /// - Parameters:
    ///   - url: 요청할 URL 객체
    ///   - completion: 요청 완료 후 호출되는 클로저
    func fetchDataFrom(url: URL, completion: @escaping (Result<Data?, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(ImageLoaderError.networkError(description: "Network Error: \(error.localizedDescription)")))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }

    func resizeImage(_ image: UIImage?, defaultImage: UIImage?, with sizeOption: ImageSizeOption) -> UIImage? {
        guard let image else { return defaultImage }

        if sizeOption == .origin { return image }

        let targetSize = sizeOption.size

        // 비율 유지 리사이징
        let aspectRatio = image.size.width / image.size.height
        var newSize = targetSize

        if aspectRatio > 1 { // 가로 이미지
            newSize.height = targetSize.width / aspectRatio
        } else { // 세로 이미지
            newSize.width = targetSize.height * aspectRatio
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
