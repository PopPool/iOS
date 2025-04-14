import Alamofire
import Foundation
import RxSwift

final class ProviderImpl: Provider {

    private let disposeBag = DisposeBag()
    var timeoutTimer: Timer?

    func requestData<R: Decodable, E: RequesteResponsable>(
        with endpoint: E,
        interceptor: RequestInterceptor? = nil
    ) -> Observable<R> where R == E.Response {

        return Observable.create { [weak self] observer in
            do {
                /// 1) endpoint -> urlRequest 생성
                let urlRequest = try endpoint.getUrlRequest()

                Logger.log(
                    message: """
                    [Provider] 최종 요청 URL:
                    - URL: \(urlRequest.url?.absoluteString ?? "URL이 없습니다.")
                    - Method: \(urlRequest.httpMethod ?? "알 수 없음")
                    - Headers: \(urlRequest.allHTTPHeaderFields ?? [:])
                    요청 시각: \(Date())
                    """,
                    category: .debug
                )

                let request = AF.request(urlRequest, interceptor: interceptor)
                    .validate()
                    .responseData { [weak self] response in
                        Logger.log(
                            message: """
                            [Provider] 응답 수신:
                            - URL: \(urlRequest.url?.absoluteString ?? "URL이 없습니다.")
                            - 응답 시각: \(Date())
                            """,
                            category: .network
                        )
                        switch response.result {
                        case .success(let data):
                            // 빈 응답 처리
                            if R.self == EmptyResponse.self && data.isEmpty {
                                if let response = EmptyResponse() as? R {
                                    observer.onNext(response)
                                    observer.onCompleted()
                                    return
                                } else {
                                    observer.onError(NetworkError.decodeError)
                                }
                            }
                            do {
                                // JSON 디코딩
                                let decodedData = try JSONDecoder().decode(R.self, from: data)
                                observer.onNext(decodedData)
                                observer.onCompleted()
                            } catch {
                                Logger.log(
                                    message: "디코딩 실패: \(error.localizedDescription)",
                                    category: .error
                                )
                                observer.onError(NetworkError.decodeError)
                            }

                        case .failure(let error):
                            Logger.log(message: "요청 실패 Error:\(error)", category: .error)
                            observer.onError(error)
                        }
                    }

                return Disposables.create {
                    request.cancel()
                }

            } catch {
                Logger.log(message: "[Provider] URLRequest 생성 실패: \(error.localizedDescription)", category: .error)
                observer.onError(NetworkError.urlRequest(error))
                return Disposables.create()
            }
        }
    }

    func request<E: Requestable>(
        with request: E,
        interceptor: RequestInterceptor? = nil
    ) -> Completable {

        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let urlRequest = try request.getUrlRequest()

                Logger.log(
                    message: """
                    [Provider] 최종 요청 URL(Completable):
                    - URL: \(urlRequest.url?.absoluteString ?? "URL이 없습니다.")
                    - Method: \(urlRequest.httpMethod ?? "알 수 없음")
                    요청 시각: \(Date())
                    """,
                    category: .debug
                )

                self.executeRequest(urlRequest, interceptor: interceptor) { response in
                    Logger.log(
                        message: "응답 시각 :\(Date())",
                        category: .network
                    )

                    // 만약 헤더에 새 토큰이 있으면 저장
                    if var accessToken = response.response?.allHeaderFields["Authorization"] as? String,
                       var refreshToken = response.response?.allHeaderFields["authorization-refresh"] as? String {
                        accessToken = accessToken.replacingOccurrences(of: "Bearer ", with: "")
                        refreshToken = refreshToken.replacingOccurrences(of: "Bearer ", with: "")

                        let keyChainService = KeyChainService()
                        keyChainService.saveToken(type: .accessToken, value: accessToken)
                        keyChainService.saveToken(type: .refreshToken, value: refreshToken)
                    }

                    switch response.result {
                    case .success:
                        observer(.completed)
                    case .failure(let error):
                        Logger.log(message: "요청 실패 Error:\(error)", category: .error)
                        observer(.error(self.handleRequestError(response: response, error: error)))
                    }
                }
            } catch {
                Logger.log(message: "[Provider] URLRequest 생성 실패 (Completable): \(error.localizedDescription)", category: .error)
                observer(.error(NetworkError.urlRequest(error)))
            }

            return Disposables.create()
        }
    }

    // multipart 업로드는 기존 코드와 동일
    func uploadImages(
        with request: MultipartEndPoint,
        interceptor: RequestInterceptor? = nil
    ) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let urlRequest = try request.asURLRequest()
                Logger.log(
                    message: """
                    [Provider] 이미지 업로드 요청:
                    - URL: \(urlRequest.url?.absoluteString ?? "URL이 없습니다.")
                    - Method: \(urlRequest.httpMethod ?? "알 수 없음")
                    """,
                    category: .network
                )

                AF.upload(multipartFormData: { multipartFormData in
                    request.asMultipartFormData(multipartFormData: multipartFormData)
                    Logger.log(message: "업로드 시각 :\(Date())", category: .network)
                }, with: urlRequest, interceptor: interceptor)
                .validate()
                .response { response in
                    Logger.log(
                        message: "이미지 업로드 응답 시각 :\(Date())",
                        category: .network
                    )
                    switch response.result {
                    case .success:
                        observer(.completed)
                    case .failure(let error):
                        observer(.error(error))
                    }
                }
            } catch {
                observer(.error(error))
            }

            return Disposables.create()
        }
    }
}

// MARK: - Private Methods
private extension ProviderImpl {
    func executeRequest(
        _ urlRequest: URLRequest,
        interceptor: RequestInterceptor?,
        completion: @escaping (AFDataResponse<Data?>) -> Void
    ) {
        // 여기서도 최종 URL 찍을 수 있음
        Logger.log(
            message: """
            [Provider] executeRequest:
            - URL: \(urlRequest.url?.absoluteString ?? "URL이 없습니다.")
            요청 시각: \(Date())
            """,
            category: .debug
        )

        AF.request(urlRequest, interceptor: interceptor)
            .validate()
            .response(completionHandler: completion)
    }

    func handleRequestError(
        response: AFDataResponse<Data?>,
        error: AFError
    ) -> Error {
        if let data = response.data,
           let errorMessage = String(data: data, encoding: .utf8) {
            return NetworkError.serverError(errorMessage)
        } else {
            return error
        }
    }
}
