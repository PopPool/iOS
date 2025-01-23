//
//  ProviderImpl.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 8/16/24.
//

import Foundation

import RxSwift
import Alamofire

final class ProviderImpl: Provider {
    
    private let disposeBag = DisposeBag()
    
    var timeoutTimer: Timer?
    
    func requestData<R: Decodable, E: RequesteResponsable>(
        with endpoint: E,
        interceptor: RequestInterceptor? = nil
    ) -> Observable<R> where R == E.Response {

        return Observable.create { [weak self] observer in
            do {
                let urlRequest = try endpoint.getUrlRequest()
                Logger.log(message: "\(urlRequest) 요청 시간 :\(Date.now)", category: .network)

                let request = AF.request(urlRequest, interceptor: interceptor)
                    .validate()
                    .responseData { [weak self] response in
                        Logger.log(message: "\(urlRequest) 응답 시간 :\(Date.now)", category: .network)
                        switch response.result {
                        case .success(let data):
                            // EmptyResponse 타입이고 데이터가 비어있는 경우 성공으로 처리
                            if R.self == EmptyResponse.self && (data.isEmpty || data.count == 0) {
                                observer.onNext(EmptyResponse() as! R)
                                observer.onCompleted()
                                return
                            }

                            do {
                                let decodedData = try JSONDecoder().decode(R.self, from: data)
                                observer.onNext(decodedData)
                                observer.onCompleted()
                            } catch {
                                Logger.log(message: "\(urlRequest) Decording 실패", category: .error)
                                observer.onError(NetworkError.decodeError)
                            }
                        case .failure(let error):
                            Logger.log(message: "\(urlRequest) 요청 실패 Error:\(error)", category: .error)
                            observer.onError(error)
                        }
                    }

                return Disposables.create {
                    request.cancel()
                }
            } catch {
                Logger.log(message: "\(endpoint) URL생성 실패", category: .error)
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
                self.executeRequest(urlRequest, interceptor: interceptor) { response in
                    Logger.log( message: "응답 시간 :\(Date.now)", category: .network)
                    
                        if var accessToken = response.response?.allHeaderFields["Authorization"] as? String,
                           var refreshToken = response.response?.allHeaderFields["Authorization-refresh"] as? String {
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
                Logger.log(message: "URL생성 실패", category: .error)
                observer(.error(NetworkError.urlRequest(error)))
            }
            
            return Disposables.create()
        }
    }
    
    /// 이미지와 데이터를 `multipart/form-data`로 업로드하는 메서드
    func uploadImages(
        with request: MultipartEndPoint,
        interceptor: RequestInterceptor? = nil
    ) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }
            
            // `multipartFormData`를 사용하여 이미지와 데이터를 업로드
            do {
                let urlRequest = try request.asURLRequest()
                AF.upload(multipartFormData: { multipartFormData in
                    request.asMultipartFormData(multipartFormData: multipartFormData)
                    Logger.log(message: "\(urlRequest)요청 시간 :\(Date.now)", category: .network)
                }, with: urlRequest, interceptor: interceptor)
                .validate()  // 서버 응답 검증
                .response { response in
                    Logger.log(message: "\(urlRequest) 응답 시간 :\(Date.now)", category: .network)
                    switch response.result {
                    case .success:
                        observer(.completed)
                    case .failure(let error):
                        observer(.error(error))
                    }
                }
            } catch {
                observer(.error(error))  // 오류가 발생한 경우 에러를 observer에 전달
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Private Methods
private extension ProviderImpl {
    
    /// 네트워크 요청을 수행하고, JSON 데이터를 디코딩하여 Observable로 반환하는 메서드
    /// - Parameters:
    ///   - urlRequest: 수행할 URLRequest 객체
    ///   - interceptor: 요청에 사용할 RequestInterceptor (옵셔널)
    ///   - observer: 네트워크 요청의 결과를 처리할 Observer
    private func executeRequest<R: Decodable>(
        _ urlRequest: URLRequest,
        interceptor: RequestInterceptor?,
        observer: AnyObserver<R>
    ) {
        Logger.log(message: "\(urlRequest) 요청 시간 :\(Date.now)", category: .network)
        
        AF.request(urlRequest, interceptor: interceptor)
            .validate()  // 응답 검증
            .responseData { response in
                
                Logger.log(message: "\(urlRequest) 응답 시간 :\(Date.now)", category: .network)
                
                switch response.result {
                case .success(let data):
                    do {
                        // 응답 데이터를 디코딩
                        let decodedData = try JSONDecoder().decode(R.self, from: data)
                        observer.onNext(decodedData)
                        observer.onCompleted()
                    } catch {
                        Logger.log(message: "\(urlRequest) Decording 실패", category: .error)
                        // 디코딩 오류 시 에러 전달
                        observer.onError(NetworkError.decodeError)
                    }
                case .failure(let error):
                    Logger.log(message: "\(urlRequest) 요청 실패 Error:\(error)", category: .error)
                    // 요청 실패 시 에러 전달
                    observer.onError(error)
                }
            }
    }
    
    /// 네트워크 요청을 수행하고, 결과를 Completion 핸들러로 처리하는 메서드
    /// - Parameters:
    ///   - urlRequest: 수행할 URLRequest 객체
    ///   - interceptor: 요청에 사용할 RequestInterceptor (옵셔널)
    ///   - completion: 네트워크 요청의 결과를 처리할 Completion 핸들러
    private func executeRequest(
        _ urlRequest: URLRequest,
        interceptor: RequestInterceptor?,
        completion: @escaping (AFDataResponse<Data?>) -> Void
    ) {
        
        Logger.log(message: "\(urlRequest)요청 시간 :\(Date.now)", category: .network)
        
        AF.request(urlRequest, interceptor: interceptor)
            .validate()  // 응답 검증
            .response(completionHandler: completion)
    }
    
    /// 네트워크 요청 실패 시 에러를 처리하는 메서드
    /// - Parameters:
    ///   - response: AFDataResponse 객체
    ///   - error: 발생한 AFError
    /// - Returns: 적절한 Error 객체를 반환
    private func handleRequestError(response: AFDataResponse<Data?>, error: AFError) -> Error {
        if let data = response.data,
           let errorMessage = String(data: data, encoding: .utf8) {
            // 서버로부터 받은 에러 메시지를 사용해 에러 생성
            return NetworkError.serverError(errorMessage)
        } else {
            // 일반적인 AFError 반환
            return error
        }
    }
}
