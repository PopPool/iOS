import Foundation

import Infrastructure

import Alamofire
import RxSwift

public final class ProviderImpl: Provider {

    private let disposeBag = DisposeBag()
    var timeoutTimer: Timer?

    public init(timeoutTimer: Timer? = nil) { self.timeoutTimer = timeoutTimer }

    public func requestData<R: Decodable, E: RequesteResponsable>(
        with endpoint: E,
        interceptor: RequestInterceptor? = nil
    ) -> Observable<R> where R == E.Response {

        return Observable.create { [weak self] observer in
            do {
                /// 1) endpoint -> urlRequest 생성
                let urlRequest = try endpoint.getUrlRequest()



                let request = AF.request(urlRequest, interceptor: interceptor)
                    .validate()
                    .responseData { [weak self] response in
                        Logger.log(
                            """
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
                                    "디코딩 실패: \(error.localizedDescription)",
                                    category: .error
                                )
                                observer.onError(NetworkError.decodeError)
                            }

                        case .failure(let error):
                            Logger.log("요청 실패 Error:\(error)", category: .error)
                            observer.onError(error)
                        }
                    }

                return Disposables.create {
                    request.cancel()
                }

            } catch {
                Logger.log("[Provider] URLRequest 생성 실패: \(error.localizedDescription)", category: .error)
                observer.onError(NetworkError.urlRequest(error))
                return Disposables.create()
            }
        }
    }

    public func request<E: Requestable>(
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


                self.executeRequest(urlRequest, interceptor: interceptor) { response in
                    Logger.log(
                        "응답 시각 :\(Date())",
                        category: .network
                    )

                    // 만약 헤더에 새 토큰이 있으면 저장
                    if var accessToken = response.response?.allHeaderFields["Authorization"] as? String,
                       var refreshToken = response.response?.allHeaderFields["authorization-refresh"] as? String {
                        accessToken = accessToken.replacingOccurrences(of: "Bearer ", with: "")
                        refreshToken = refreshToken.replacingOccurrences(of: "Bearer ", with: "")

                        @Dependency var keyChainService: KeyChainService
                        keyChainService.saveToken(type: .accessToken, value: accessToken)
                        keyChainService.saveToken(type: .refreshToken, value: refreshToken)
                    }

                    switch response.result {
                    case .success:
                        observer(.completed)
                    case .failure(let error):
                        Logger.log("요청 실패 Error:\(error)", category: .error)
                        observer(.error(self.handleRequestError(response: response, error: error)))
                    }
                }
            } catch {
                Logger.log("[Provider] URLRequest 생성 실패 (Completable): \(error.localizedDescription)", category: .error)
                observer(.error(NetworkError.urlRequest(error)))
            }

            return Disposables.create()
        }
    }

    // multipart 업로드는 기존 코드와 동일
    public func uploadImages(
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


                AF.upload(multipartFormData: { multipartFormData in
                    request.asMultipartFormData(multipartFormData: multipartFormData)
                    Logger.log("업로드 시각 :\(Date())", category: .network)
                }, with: urlRequest, interceptor: interceptor)
                .validate()
                .response { response in
                    Logger.log(
                        "이미지 업로드 응답 시각 :\(Date())",
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
