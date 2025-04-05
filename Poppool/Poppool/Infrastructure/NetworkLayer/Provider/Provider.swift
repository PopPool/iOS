//
//  Provider.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 8/16/24.
//

import Foundation

import Alamofire
import RxSwift

protocol Provider {

    /// 네트워크 요청을 수행하고 결과를 반환하는 메서드
    /// - Parameters:
    ///   - endpoint: 요청할 엔드포인트
    ///   - interceptor: 요청에 사용할 RequestInterceptor (옵셔널)
    ///   - isShowIndicator: indicator 활성화 여부
    /// - Returns: 요청에 대한 결과를 Observable로 반환
    func requestData<R: Decodable, E: RequesteResponsable>(
        with endpoint: E,
        interceptor: RequestInterceptor?
    ) -> Observable<R> where R == E.Response

    /// 네트워크 요청을 수행하고 결과를 반환하는 메서드
    /// - Parameters:
    ///   - request: 요청할 Requestable 객체
    ///   - interceptor: 요청에 사용할 RequestInterceptor (옵셔널)
    ///   - isShowIndicator: indicator 활성화 여부
    /// - Returns: 요청에 대한 결과를 Completable로 반환
    func request<E: Requestable>(
        with request: E,
        interceptor: RequestInterceptor?
    ) -> Completable

    /// 이미지와 데이터를 `multipart/form-data`로 업로드하는 메서드
    func uploadImages(
        with request: MultipartEndPoint,
        interceptor: RequestInterceptor?
    ) -> Completable
}
