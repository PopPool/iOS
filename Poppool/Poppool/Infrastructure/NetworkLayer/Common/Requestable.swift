//
//  Requestable.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 8/16/24.
//

import Foundation

import Alamofire

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

        Logger.log(
            message: "\(url) URL 생성",
            category: .network,
            fileName: #file,
            line: #line
        )

        var urlRequest = URLRequest(url: url)
        // httpBody
        if let bodyParameters = try bodyParameters?.toDictionary() {
            if !bodyParameters.isEmpty {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
                print(bodyParameters)
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
        guard var urlComponents = URLComponents(string: fullPath) else {
            throw NetworkError.components
        }
        // (baseURL + path) + queryParameters
        var urlQueryItems = [URLQueryItem]()
        if let queryParameters = try queryParameters?.toDictionary() {
            queryParameters.forEach {
                if $0.key == "sort" {
                    let input = "\($0.value)"
                    let key = $0.key
                    let trimmed = input.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
                    let withoutBrackets = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                    let result = withoutBrackets.split(separator: ",").map { String($0) }
                    result.forEach { sort in urlQueryItems.append(URLQueryItem(name: key, value: sort))}
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
