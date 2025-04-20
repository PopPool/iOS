import UIKit

public extension Optional where Wrapped == String {
    /// ISO 8601 형식의 문자열을 `Date`로 변환하는 메서드
    func toDate() -> Date? {
        guard let self = self else { return nil } // 옵셔널 해제

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if self.contains(".") {
            // 밀리초 포함 형식
            dateFormatter.dateFormat = "yyyy.MM.dd'T'HH:mm:ss.SSS"
        } else {
            // 밀리초 없는 형식
            dateFormatter.dateFormat = "yyyy.MM.dd'T'HH:mm:ss"
        }

        return dateFormatter.date(from: self)
    }

    func isBrightImagePath(completion: @escaping (Bool) -> Void) {
        if let self = self {
            let imageView = UIImageView()
            imageView.setPPImage(path: self) {
                completion(imageView.image?.isBright() ?? true)
            }
        } else {
            completion(true)
        }
    }
}

extension String {
    func isBrightImagePath(completion: @escaping (Bool) -> Void) {
        let imageView = UIImageView()
        imageView.setPPImage(path: self) {
            completion(imageView.image?.isBright() ?? true)
        }
    }
}
extension String {
    /// ISO 8601 형식의 문자열을 `Date`로 변환하는 메서드
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if self.contains(".") {
            // 밀리초 포함 형식
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        } else {
            // 밀리초 없는 형식
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }

        return dateFormatter.date(from: self)
    }
}
