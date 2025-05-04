import ObjectiveC
import UIKit

private var currentURLKey: UInt8 = 0
private var placeholderImageKey: UInt8 = 0

public extension UIImageView {

    private var currentImageURL: String? {
        get { objc_getAssociatedObject(self, &currentURLKey) as? String }
        set { objc_setAssociatedObject(self, &currentURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var placeholderImage: UIImage? {
        get { objc_getAssociatedObject(self, &placeholderImageKey) as? UIImage }
        set { objc_setAssociatedObject(self, &placeholderImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setPPImage(path: String?) {
        // 기본 이미지 저장
        if placeholderImage == nil {
            placeholderImage = UIImage(named: "image_default")
        }

        guard let path = path, !path.isEmpty else {
            image = placeholderImage
            currentImageURL = nil
            return
        }

        let imageURLString = Secrets.popPoolS3BaseURL + path
        guard let encodedURL = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            image = placeholderImage
            currentImageURL = nil
            return
        }

        // 이미 같은 URL을 로딩했고 이미지가 있으면 재로딩 방지
        if currentImageURL == encodedURL && self.image != nil && self.image != placeholderImage {
            return
        }

        // 현재 이미지 URL을 업데이트
        currentImageURL = encodedURL

        // 먼저 메모리 캐시 확인
        if let cachedImage = MemoryStorage.shared.fetchImage(url: encodedURL) {
            self.image = cachedImage
            return
        }

        // 다음으로 디스크 캐시 확인
        if let diskImage = DiskStorage.shared.fetchImage(url: encodedURL) {
            MemoryStorage.shared.store(image: diskImage, url: encodedURL)
            self.image = diskImage
            return
        }

        ImageLoader.shared.loadImage(with: encodedURL, defaultImage: placeholderImage, imageQuality: .origin) { [weak self] image in
            guard let self else { return }

            DispatchQueue.main.async {
                // 현재 요청 ID와 캡처된 ID가 일치하는지 확인 (다른 이미지로 변경되었으면 무시)
                if self.currentImageURL == encodedURL {
                    if let image = image {
                        self.image = image
                    } else if self.image == nil {
                        // 이미지 로드 실패 시 기본 이미지 표시
                        self.image = self.placeholderImage
                    }
                }
            }
        }
    }

    func setPPImage(path: String?, completion: @escaping () -> Void) {
        // 기본 이미지 저장
        if placeholderImage == nil {
            placeholderImage = UIImage(named: "image_default")
        }

        guard let path = path, !path.isEmpty else {
            image = placeholderImage
            currentImageURL = nil
            completion()
            return
        }

        let imageURLString = Secrets.popPoolS3BaseURL + path
        guard let encodedURL = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            image = placeholderImage
            currentImageURL = nil
            completion()
            return
        }

        // 이미 같은 URL을 로딩했고 이미지가 있으면 재로딩 방지
        if currentImageURL == encodedURL && self.image != nil && self.image != placeholderImage {
            completion()
            return
        }

        // 현재 이미지 URL을 업데이트
        currentImageURL = encodedURL

        // 먼저 메모리 캐시 확인
        if let cachedImage = MemoryStorage.shared.fetchImage(url: encodedURL) {
            self.image = cachedImage
            completion()
            return
        }

        // 다음으로 디스크 캐시 확인
        if let diskImage = DiskStorage.shared.fetchImage(url: encodedURL) {
            MemoryStorage.shared.store(image: diskImage, url: encodedURL)
            self.image = diskImage
            completion()
            return
        }

        ImageLoader.shared.loadImage(with: encodedURL, defaultImage: placeholderImage, imageQuality: .origin) { [weak self] image in
            DispatchQueue.main.async {
                defer { completion() }

                guard let self else { return }

                // 현재 요청 ID와 캡처된 ID가 일치하는지 확인 (다른 이미지로 변경되었으면 무시)
                if self.currentImageURL == encodedURL {
                    if let image = image {
                        self.image = image
                    } else if self.image == nil {
                        // 이미지 로드 실패 시 기본 이미지 표시
                        self.image = self.placeholderImage
                    }
                }
            }
        }
    }
}
