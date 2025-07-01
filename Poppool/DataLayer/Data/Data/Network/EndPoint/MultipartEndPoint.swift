import UIKit

import Infrastructure

import Alamofire

public class MultipartEndPoint: URLRequestConvertible {
    var baseURL: String
    var path: String
    var method: HTTPMethod
    var parameters: [String: Any]?
    var jsonData: [String: Any]?
    var images: [UIImage]
    var headers: [String: String]?

    init(
        baseURL: String,
        path: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        jsonData: [String: Any]? = nil,
        images: [UIImage],
        headers: [String: String]? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.parameters = parameters
        self.jsonData = jsonData
        self.images = images
        self.headers = headers
    }

    public func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        Logger.log("\(request) URL 생성", category: .network)
        request.method = method

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        return request
    }

    func asMultipartFormData(multipartFormData: MultipartFormData) {
        // JSON 데이터를 data 필드로 추가
        if let jsonData = jsonData {
            // JSON 객체를 Data로 변환
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonData, options: [])
                // JSON 문자열로 변환
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    multipartFormData.append(jsonString.data(using: .utf8)!, withName: "data")
                }
            } catch {
                Logger.log("JSON 변환 오류: \(error)", category: .network)
            }
        }

        // 이미지 파일 추가
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                multipartFormData.append(
                    imageData,
                    withName: "image",
                    fileName: "image\(index).jpg",
                    mimeType: "image/jpeg"
                )
            }
        }
    }
}
