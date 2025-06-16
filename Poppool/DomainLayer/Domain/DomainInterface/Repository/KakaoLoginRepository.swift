import Foundation

import RxSwift

public protocol KakaoLoginRepository {
    func fetchUserCredential() -> Observable<AuthServiceResponse>
}
