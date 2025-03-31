import UIKit

//URL을 사용한 이미지 로드
//메모리 캐싱
//디스크 캐싱
//일정 시간 후 캐싱 데이터를 제거
//이미지 리사이징 모듈

enum ImageLoaderError: Error {
    case invalidURL
    case networkError(description: String?)
}

class ImageLoader {
    
    static let shared = ImageLoader()
    
    private init() {}
    
    func loadImage(with stringURL: String?, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let stringURL = stringURL,
              let url = URL(string: stringURL) else {
            completion(.failure(ImageLoaderError.invalidURL))
            return
        }
        
        fetchImageFrom(url: url) { result in
            completion(result)
        }
    }
}

private extension ImageLoader {
    func fetchImageFrom(url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(ImageLoaderError.networkError(description: "Network Error: \(error.localizedDescription)")))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(ImageLoaderError.networkError(description: "Network Error: Invalid image data")))
                return
            }
            
            completion(.success(image))
        }
        task.resume()
    }
}
