//
//  Networkable.swift
//  PopPool
//
//  Created by Porori on 6/2/24.
//

import Foundation
import Alamofire
/// 요청 URL
protocol Requestable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: Encodable? { get }
    var bodyParameters: Encodable? { get }
    var headers: [String: String]? { get }
    var sampleData: Data? { get }
}

extension Requestable {
    /// APIEndpoint에서 전달받은 DTO를 URLRequest로 변환하는 메서드
    /// - Returns: URLRequest 반환
    func getUrlRequest() throws -> URLRequest {
        let url = try url()
        print("생성된 url 링크:",url)
        var urlRequest = URLRequest(url: url)

        // httpBody
        if let bodyParameters = try bodyParameters?.toDictionary() {
            if !bodyParameters.isEmpty {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
            }
        }

        // httpMethod
        urlRequest.httpMethod = method.rawValue

        // header
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        return urlRequest
    }

    /// APIEndpoint에서 전달받은 DTO를 URL로 변환하는 메서드
    /// - Returns: URL 반환
    func url() throws -> URL {

        // baseURL + path
        let fullPath = "\(baseURL)\(path)"
        guard var urlComponents = URLComponents(string: fullPath) else { throw NetworkError.components }

        // (baseURL + path) + queryParameters
        var urlQueryItems = [URLQueryItem]()
        if let queryParameters = try queryParameters?.toDictionary() {
            queryParameters.forEach {
                if $0.key == "sort" {
                    let value = "\($0.value)"
                    let valueList = value
                        .components(separatedBy: "\n")
                        .filter {!["(",")",","].contains($0)}
                        .map { $0.replacingOccurrences(of: " ", with: "")}

                    for valueString in valueList {
                        urlQueryItems.append(URLQueryItem(name: $0.key, value: valueString))
                    }

                } else {
                    urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
                }
            }
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil

        guard let url = urlComponents.url else { throw NetworkError.components }
        return url
    }
}

extension Encodable {

    /// URL에 요청할 쿼리 데이터를 JSON 형식에 맞게 딕셔너리 구조로 변환하는 메서드
    /// - Returns: jsonData
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String: Any]
    }
}
