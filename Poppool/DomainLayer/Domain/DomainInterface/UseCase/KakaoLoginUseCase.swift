import Foundation

import RxSwift

public protocol KakaoLoginUseCase {
    func fetchUserCredential() -> Observable<AuthServiceResponse>
}
