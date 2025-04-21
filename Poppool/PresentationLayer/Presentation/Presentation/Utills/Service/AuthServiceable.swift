import Foundation

import DomainInterface

import RxSwift

protocol AuthServiceable: AnyObject {
    /// 사용자 자격 증명을 가져오는 함수
    /// - Returns: Response 형태의 사용자 자격 증명
    func fetchUserCredential() -> Observable<AuthServiceResponse>
}

enum AuthError: Error {
    case notInstalled
    case unknownError(description: String?)
}
