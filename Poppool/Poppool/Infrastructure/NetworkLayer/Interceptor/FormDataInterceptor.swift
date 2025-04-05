//
//  FormDataInterceptor.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 10/25/24.
//

import Alamofire
import Foundation
import RxSwift

final class FormDataInterceptor: RequestInterceptor {

    private var disposeBag = DisposeBag()

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        Logger.log(message: "FormDataInterceptor Retry Start", category: .network)
    }
}
